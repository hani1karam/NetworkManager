//
//  SessionManager.swift
//  NetworkManager
//
//  Created by Mac on 29/06/2022.
//

import Alamofire

extension SessionManager {
    func request(url: URLConvertible, method: HTTPMethod, parameters: Parameters? = nil, encoding: ParameterEncoding, headers: HTTPHeaders? = nil)  -> DataRequest {
        return self.request(url, method: method, parameters: parameters, encoding: encoding)
    }
}

struct APIClient: DataProviderProtocol {
    func sentRequest<ResponseType>(request: RequestProtocol, mapResponseOnType: ResponseType.Type, successHandler: @escaping (ResponseType) -> Void, failureHandler: @escaping (Error) -> Void) where ResponseType : Decodable, ResponseType : Encodable {
        SessionManagerBuilder.shared.manager.request(request.url, method: request.method, parameters: request.parameters, encoding: URLEncoding.methodDependent, headers: [:])
            .validate(statusCode: 200..<600).responseJSON { (response) in
                switch response.result {
                case .success:
                    do {
                        if (response.result.value) != nil{
                            print(response.result)
                            do{
                                guard let data = response.data else { return }
                                let response = try JSONDecoder().decode(ResponseType.self, from: data)
                                successHandler(response)
                            }catch let err{
                                print("Error In Decode Data \(err.localizedDescription)")
                                failureHandler(err)
                            }
                        }
                    } catch {
                        failureHandler(error)
                    }
                case .failure(let error):
                    // Error executing the request
                    debugPrint(error,error.localizedDescription)
                    failureHandler(error)
                }
            }
    }
}
class SessionManagerBuilder {
    
    static let shared = SessionManagerBuilder()
    
    let manager: Alamofire.SessionManager = {
        let availableCertificatesInProjectDirectory = SessionManagerBuilder.certificates()
        let domainName = "YOUR DOMIN WITHOUT HTTPS"
        
        let serverTrustPolicies: [String: ServerTrustPolicy] =
        [
            domainName: .pinCertificates(certificates: availableCertificatesInProjectDirectory, validateCertificateChain: true, validateHost: true)
        ]
        
        let configuration = URLSessionConfiguration.default
        configuration.urlCredentialStorage = nil
        configuration.httpShouldUsePipelining = true
        configuration.timeoutIntervalForRequest = TimeInterval(10)
        
        return Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }()
    
    private static func certificates(in bundle: Bundle = Bundle.main) -> [SecCertificate] {
        var certificates: [SecCertificate] = []
        
        let paths = Set([".cer", ".CER", ".crt", ".CRT", ".der", ".DER"].map { fileExtension in
            bundle.paths(forResourcesOfType: fileExtension, inDirectory: nil)
        }.joined())
        
        for path in paths {
            do {
                
                let certificateData = try Data(contentsOf: URL(fileURLWithPath: path)) as CFData
                let certificate = SecCertificateCreateWithData(nil, certificateData)
                if let cert = certificate {
                    certificates.append(cert)
                }
            } catch {
                print( error )
            }
        }
        return certificates
    }
}
