//
//  ClientCredentialsManager.swift
//  TrustAudit
//
//  Created by Kevin Torres on 9/23/19.
//  Copyright © 2019 Kevin Torres. All rights reserved.
//

// MARK: - ClientCredentialsManagerProtocol
protocol AuditClientCredentialsManagerProtocol: AnyObject {
    func save(clientCredentials: AuditClientCredentials)
    func getClientCredentials() -> AuditClientCredentials?
    func deleteClientCredentials()
}

// MARK: - AuditClientCredentialsManagerOutputProtocol
protocol AuditClientCredentialsManagerOutputProtocol: AnyObject {
    func onClientCredentialsSaved(savedClientCredentials: AuditClientCredentials)
}

// MARK: - ClientCredentialsManager
final class ClientCredentialsManager {
    weak var managerOutput: AuditClientCredentialsManagerOutputProtocol?

    var accessGroup: String
    var serviceName: String

    var keychain: KeychainWrapper {
        return KeychainWrapper(serviceName: serviceName, accessGroup: accessGroup)
    }

    init(serviceName: String, accessGroup: String) {
        self.serviceName = serviceName
        self.accessGroup = accessGroup
    }
}

// MARK: - AuditClientCredentialsManagerProtocol
extension ClientCredentialsManager: AuditClientCredentialsManagerProtocol {
    func save(clientCredentials: AuditClientCredentials) {
        guard
            let tokenType = clientCredentials.tokenType,
            let accessToken = clientCredentials.accessToken else {return}

        keychain.set(tokenType, forKey: "tokenType")
        keychain.set(accessToken, forKey: "accessToken")

        managerOutput?.onClientCredentialsSaved(savedClientCredentials: clientCredentials)
    }

    func getClientCredentials() -> AuditClientCredentials? {
        guard
            let tokenType = keychain.string(forKey: "tokenType"),
            let accessToken = keychain.string(forKey: "accessToken") else { return nil }

        let clientCredentials = AuditClientCredentials()

        clientCredentials.tokenType = tokenType
        clientCredentials.accessToken = accessToken

        return clientCredentials
    }

    func deleteClientCredentials() {
        keychain.remove(key: "accessToken")
        keychain.remove(key: "tokenType")
    }
}
