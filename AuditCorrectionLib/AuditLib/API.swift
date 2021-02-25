//
//  API.swift
//  TrustAudit
//
//  Created by Kevin Torres on 8/14/19.
//  Copyright © 2019 Kevin Torres. All rights reserved.
//

import Alamofire

// MARK: - ResponseStatus Enum
public enum ResponseStatusT: String {
    case noChanges = "No hay cambios"
    case updated = "Datos actualizados"
    case error = "Ha ocurrido un error en el envío de datos"
}

// MARK: - StatusCode Enum
enum StatusCode: Int {
    case invalidToken = 401
}

// MARK: - API class
class API {
    static let baseURL = "https://api.trust.lat" // Prod
    static let baseURLTest = "https://api-tst.trust.lat" // Test

    static let clientCredentialsBaseURL = "https://atenea.trust.lat" // Credentials Prod
    static let clientCredentialsBaseURLTest = "https://atenea-tst.trust.lat" // Credentials Test

    static let apiVersion = "/api/v1"
}

extension API {
    private static func handle(statusCode: Int, completion: CompletionHandler) {
        switch statusCode {
        case 401:
            let parameters = ClientCredentialsParameters(
                clientID: "adcc11078bee4ba2d7880a48c4bed02758a5f5328276b08fa14493306f1e9efb",
                clientSecret: "1f647aab37f4a7d7a0da408015437e7a963daca43da06a7789608c319c2930bd"
            )

            call(
                resource: APIRouter.clientCredentials(parameters: parameters),
                onResponse: nil,
                onSuccess: {
                    (responseData: AuditClientCredentials) in

                    let serviceName = TrustAudit.serviceName
                    let accessGroup = TrustAudit.accessGroup

                    let clientCredentialsManager = ClientCredentialsManager(serviceName: serviceName, accessGroup: accessGroup)

                    clientCredentialsManager.save(clientCredentials: responseData)

                    completion?()
                }
            )
        default: break
        }
    }

    // MARK: - call<T: Mappable>(onResponse: CompletionHandler), onResponse without response data
    @discardableResult
    static func call<T: Decodable>(resource: URLRequestConvertible, onResponse: CompletionHandler = nil, onSuccess: SuccessHandler<T> = nil, onFailure: CompletionHandler = nil) -> DataRequest {

        var jsonDecoder: JSONDecoder {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            return jsonDecoder
        }
        
        return AF
            .request(resource)
            .responseDecodable(decoder: jsonDecoder) { (response: AFDataResponse<T>) in
                print("API.call() Response: \(response)")

                onResponse?()

                guard let statusCode = response.response?.statusCode else { return }

                handle(statusCode: statusCode) {
                    call(
                        resource: resource,
                        onResponse: onResponse,
                        onSuccess: onSuccess,
                        onFailure: onFailure
                    )
                }

                switch response.result {
                case .success(let decodedObject): onSuccess?(decodedObject)
                case .failure(let error):
                    print("error.localizedDescription: \(error.localizedDescription)")
                    onFailure?()
                }
            }
    }
}
