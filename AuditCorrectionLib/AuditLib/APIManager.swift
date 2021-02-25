//
//  APIManager.swift
//  TrustAudit
//
//  Created by Kevin Torres on 8/14/19.
//  Copyright © 2019 Kevin Torres. All rights reserved.
//

// MARK: - APIManagerProtocol
protocol APIManagerProtocol: AnyObject {
    func getClientCredentials(with parameters: AuditClientCredentialsParameters)
    func createAudit(with parameters: AuditParameters)
    func udCreateAudit<T>(with parameters: UDCreateAuditParameters<T>)
}

// MARK: - APIManagerOutputProtocol
protocol APIManagerOutputProtocol: AnyObject {
    func onClientCredentialsResponse()
    func onClientCredentialsSuccess(responseData: AuditClientCredentials)
    func onClientCredentialsFailure()

    func onCreateAuditResponse()
    func onCreateAuditSuccess(responseData: CreateAuditResponse, parameters: AuditParameters)
    func onCreateAuditFailure()

    func onCreateUDAuditResponse()
    func onCreateUDAuditSuccess<T>(responseData: CreateAuditResponse, parameters: UDCreateAuditParameters<T>)
    func onCreateUDAuditFailure()
}

// MARK: - APIManager
final class APIManager {
    weak var managerOutput: APIManagerOutputProtocol?
}

// MARK: - APIManagerProtocol
extension APIManager: APIManagerProtocol {
//    func getClientCredentials(with parameters: AuditClientCredentialsParameters) {
//        API.call(
//            resource: APIRouter.clientCredentials(parameters: parameters),
//            onResponse: { [weak self] in
//                guard let self = self else { return }
//                self.managerOutput?.onClientCredentialsResponse()
//            }, onSuccess: { [weak self] (responseData: AuditClientCredentials) in
//                guard let self = self else { return }
//                self.managerOutput?.onClientCredentialsSuccess(responseData: responseData)
//            }, onFailure: { [weak self] in
//                guard let self = self else { return }
//                self.managerOutput?.onClientCredentialsFailure()
//            }
//        )
//    }
//
//    func createAudit(with parameters: AuditParameters) {
//        API.call(
//            resource: APIRouter.createAudit(parameters: parameters),
//            onResponse: { [weak self] in
//                guard let self = self else { return }
//                print("API call create audit parameters: \(parameters)")
//                self.managerOutput?.onCreateAuditResponse()
//            }, onSuccess: { [weak self] (responseData: CreateAuditResponse) in
//                guard let self = self else { return }
//                print("API call create audit parameters: \(parameters)")
//                self.managerOutput?.onCreateAuditSuccess(responseData: responseData, parameters: parameters)
//            }, onFailure: { [weak self] in
//                guard let self = self else { return }
//                self.managerOutput?.onCreateAuditFailure()
//            }
//        )
//    }
//
//    func udCreateAudit<T>(with parameters: UDCreateAuditParameters<T>) {
//        API.call(
//            resource: APIRouter.createUDAudit(parameters: parameters),
//            onResponse: { [weak self] in
//                guard let self = self else { return }
//                print("API call create audit parameters: \(parameters)")
//                self.managerOutput?.onCreateUDAuditResponse()
//            }, onSuccess: { [weak self] (responseData: CreateAuditResponse) in
//                guard let self = self else { return }
//                print("API call create audit parameters: \(parameters)")
//                self.managerOutput?.onCreateUDAuditSuccess(responseData: responseData, parameters: parameters)
//            }, onFailure: { [weak self] in
//                guard let self = self else { return }
//                self.managerOutput?.onCreateUDAuditFailure()
//            }
//        )
//    }

    func getClientCredentials(with parameters: AuditClientCredentialsParameters) {
        API.call(
            resource: APIRouter.clientCredentials(parameters: parameters),
            onResponse: {
                self.managerOutput?.onClientCredentialsResponse()
            }, onSuccess: { (responseData: AuditClientCredentials) in
                self.managerOutput?.onClientCredentialsSuccess(responseData: responseData)
            }, onFailure: {
                self.managerOutput?.onClientCredentialsFailure()
            }
        )
    }

    func createAudit(with parameters: AuditParameters) {
        API.call(
            resource: APIRouter.createAudit(parameters: parameters),
            onResponse: {
                print("API call create audit parameters: \(parameters)")
                self.managerOutput?.onCreateAuditResponse()
            }, onSuccess: { (responseData: CreateAuditResponse) in
                print("API call create audit parameters: \(parameters)")
                self.managerOutput?.onCreateAuditSuccess(responseData: responseData, parameters: parameters)
            }, onFailure: {
                self.managerOutput?.onCreateAuditFailure()
            }
        )
    }

    func udCreateAudit<T>(with parameters: UDCreateAuditParameters<T>) {
        API.call(
            resource: APIRouter.createUDAudit(parameters: parameters),
            onResponse: {
                print("API call create audit parameters: \(parameters)")
                self.managerOutput?.onCreateUDAuditResponse()
            }, onSuccess: { (responseData: CreateAuditResponse) in
                print("API call create audit parameters: \(parameters)")
                self.managerOutput?.onCreateUDAuditSuccess(responseData: responseData, parameters: parameters)
            }, onFailure: {
                self.managerOutput?.onCreateUDAuditFailure()
            }
        )
    }
}
