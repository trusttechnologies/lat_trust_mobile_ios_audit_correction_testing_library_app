//
//  APIRouter.swift
//  TrustAudit
//
//  Created by Kevin Torres on 8/14/19.
//  Copyright © 2019 Kevin Torres. All rights reserved.
//

import Alamofire

// MARK: - APIRouter
enum APIRouter: URLRequestConvertible {
    case clientCredentials(parameters: Parameterizable)
    case createAudit(parameters: Parameterizable) //Receive authorization by parameters
    case createUDAudit(parameters: Parameterizable)

    var path: String {
        switch self {
        case .clientCredentials:
            return "/oauth/token/"
        case .createAudit, .createUDAudit:
            return "/audit\(API.apiVersion)/audit"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .createAudit, .clientCredentials, .createUDAudit:
            return .post
        }
    }

    var parameters: Parameters {
        switch self {
        case .clientCredentials(let parameters):
            return parameters.asParameters
        case .createAudit(let parameters):
            return parameters.asParameters
        case .createUDAudit(let parameters):
            return parameters.asParameters
        }
    }

    func asURLRequest() throws -> URLRequest {
        var baseURLAsString: String = .empty

        switch self {
        case .clientCredentials:
            if TrustAudit.currentEnvironment == "prod" {
                baseURLAsString = API.clientCredentialsBaseURL
            } else {
                baseURLAsString = API.clientCredentialsBaseURLTest
            }
        case .createAudit, .createUDAudit:
            if TrustAudit.currentEnvironment == "prod" {
                baseURLAsString = API.baseURL
            } else {
                baseURLAsString = API.baseURLTest
            }
        }

        guard let url = URL(string: baseURLAsString) else {
            return URLRequest(url: URL(string: .empty)!)
        }

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))

        defer {
            print("urlRequest: \(urlRequest)")
            print("urlRequest.allHTTPHeaderFields: \(String(describing: urlRequest.allHTTPHeaderFields))")
            print("Parameters: \(parameters)")
        }

        urlRequest.httpMethod = method.rawValue

        switch self {
        case .createAudit, .createUDAudit:
            let serviceName = TrustAudit.serviceName
            let accessGroup = TrustAudit.accessGroup

            let clientCredentialsManager = ClientCredentialsManager(serviceName: serviceName, accessGroup: accessGroup)

            if
                let clientCredentials = clientCredentialsManager.getClientCredentials(),
                let tokenType = clientCredentials.tokenType,
                let accessToken = clientCredentials.accessToken {

                let authorizationHeaderValue = "\(tokenType) \(accessToken)"

                print(authorizationHeaderValue)

                urlRequest.addValue(authorizationHeaderValue, forHTTPHeaderField: "Authorization")
            }
        default: break
        }

        switch self {
        case .createAudit, .clientCredentials, .createUDAudit:
            return try JSONEncoding.default.encode(urlRequest, with: parameters)
        }
    }
}
