//
//  Responses.swift
//  TrustAudit
//
//  Created by Kevin Torres on 8/14/19.
//  Copyright © 2019 Kevin Torres. All rights reserved.
//

// MARK: - TrustID
public class TrustID: Codable {
    var status = false
    var message: String?
    var trustID: String?
}

// MARK: - CreateAuditResponse
public class CreateAuditResponse: Decodable {
    var status: Bool?
    var message: String?
}

// MARK: - ClientCredentials
public class AuditClientCredentials: Codable {
    public var accessToken: String?
    public var tokenType: String?
}
