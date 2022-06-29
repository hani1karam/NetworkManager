//
//  RequestProtocol.swift
//  NetworkManager
//
//  Created by Mac on 29/06/2022.
//

import Alamofire

public protocol RequestProtocol {
    var url: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders { get }
    var parameters: [String:Any] { get }
}

extension RequestProtocol {
    var headers: HTTPHeaders { return ["Content-Type" : "application/json"]}
    var parameters: Parameters { return [:] }
}

class SimpleGetRequest: RequestProtocol {
    var method: HTTPMethod
    var url: String
    var parameters: [String:Any]
    
    required init(url: String, parameters: [String:Any]?,method:HTTPMethod?) {
        self.url = url
        self.parameters = parameters ?? ["":""]
        self.method = method ?? .get
    }
}
