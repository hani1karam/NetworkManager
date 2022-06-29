//
//  DataProviderProtocol.swift
//  NetworkManager
//
//  Created by Mac on 29/06/2022.
//

import Foundation
protocol DataProviderProtocol {
    func sentRequest<ResponseType: Codable> (request: RequestProtocol, mapResponseOnType: ResponseType.Type, successHandler: @escaping (ResponseType) -> Void, failureHandler: @escaping (Error) -> Void)
}
