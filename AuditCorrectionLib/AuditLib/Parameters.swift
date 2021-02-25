//
//  Parameters.swift
//  TrustAudit
//
//  Created by Kevin Torres on 8/14/19.
//  Copyright © 2019 Kevin Torres. All rights reserved.
//

import Alamofire
import CoreTelephony
import RealmSwift

// MARK: - Object interface
// MARK: - AuditObjectProtocol
protocol AuditObjectProtocol {
    var localID: String { get }
    var auditType: String { get }
    var platform: String { get }
    var application: String { get }
}

// MARK: - AuditSourceProtocol
protocol AuditSourceProtocol {
    var trustID: String { get }
    var appName: String { get }
    var bundleID: String { get }
    var connectionType: String { get }
    var connectionName: String { get }
    var appVersion: String { get }
    var deviceName: String { get }
    var osVersion: String { get }
    var os: String { get }
}

// MARK: - AuditTransactionProtocol
protocol AuditTransactionProtocol {
    var type: String { get }
    var result: String { get }
    var timestamp: Int { get }
    var method: String { get }
    var operation: String { get }
}

// MARK: - AuditLocationProtocol
protocol AuditLocationProtocol {
    var latitude: String { get }
    var longitude: String { get }
}

// MARK: - Realm
// MARK: - AuditObject
class AuditObject: Object, AuditObjectProtocol {
    @objc dynamic var localID: String = ""
    @objc dynamic var auditType: String = ""
    @objc dynamic var platform: String = "" //iOS
    @objc dynamic var application: String = ""
    @objc dynamic var source: AuditSource?
    @objc dynamic var transaction: AuditTransaction?
    @objc dynamic var location: AuditLocation?
}

// MARK: - AuditSource
class AuditSource: Object, AuditSourceProtocol {
    @objc dynamic var trustID: String = ""
    @objc dynamic var appName: String = ""
    @objc dynamic var bundleID: String = ""
    @objc dynamic var connectionType: String = ""
    @objc dynamic var connectionName: String = ""
    @objc dynamic var appVersion: String = ""
    @objc dynamic var deviceName: String = ""
    @objc dynamic var osVersion: String = ""
    @objc dynamic var os: String = ""
}
// MARK: - AuditTransaction
class AuditTransaction: Object, AuditTransactionProtocol {
    @objc dynamic public var type: String = ""
    @objc dynamic public var result: String = ""
    @objc dynamic public var timestamp: Int = 1
    @objc dynamic public var method: String = ""
    @objc dynamic public var operation: String = ""
}

// MARK: - AuditLocation
class AuditLocation: Object, AuditLocationProtocol {
    @objc dynamic public var latitude: String = ""
    @objc dynamic public var longitude: String = ""
}

// MARK: - ---------------
// MARK: - AuditParameters
class AuditParameters: Parameterizable, AuditObjectProtocol {
    var localID: String = ""
    var auditType: String = ""
    var platform: String = "" //iOS
    var application: String = ""
    var source: Source?
    var transaction: Transaction?
    var location: Location?

    public var asParameters: Parameters {
        return [
            "type_audit": auditType,
            "platform": platform,
            "application": application,
            "source": source?.asParameters,
            "transaction": transaction?.asParameters,
            "location": location?.asParameters
        ]
    }
}

// MARK: - ClientCredentialsParameters
struct ClientCredentialsParameters: Parameterizable {
    var clientID: String?
    var clientSecret: String?

    let grantType = "client_credentials"

    public var asParameters: Parameters {
        guard
            let clientID = clientID,
            let clientSecret = clientSecret else {
                return [:]
        }

        return [
            "client_id": clientID,
            "client_secret": clientSecret,
            "grant_type": grantType
        ]
    }
}

// MARK: - Source
class Source: Parameterizable, AuditSourceProtocol {
    var trustID: String = ""
    var appName: String = ""
    var bundleID: String = ""
    var connectionType: String = ""
    var connectionName: String = ""
    var appVersion: String = ""
    var deviceName: String = ""
    var osVersion: String = ""
    var os: String = ""

    public var asParameters: Parameters {
        return [
            "trust_id": trustID,
            "app_name": appName,
            "bundle_id": bundleID,
            "os": os,
            "os_version": osVersion,
            "device_name": deviceName,
            "connection_type": connectionType,
            "connection_name": connectionName,
            "version_app": appVersion
        ]
    }
}

// MARK: - Transaction
public class Transaction: Parameterizable, AuditTransactionProtocol {
    var type: String = ""
    var result: String = ""
    var timestamp: Int = 1
    var method: String = ""
    var operation: String = ""

    public var asParameters: Parameters {
        return [
            "type": type,
            "result": result,
            "timestamp": timestamp,
            "method": method,
            "operation": operation
        ]
    }
}

// MARK: - Location
public class Location: Parameterizable, AuditLocationProtocol {
    var latitude: String = ""
    var longitude: String = ""

    public var asParameters: Parameters {
        return [
            "lat_geo": latitude,
            "lon_geo": longitude,
        ]
    }
}

// MARK: - ---------------------------
// MARK: - ClientCredentialsParameters
struct AuditClientCredentialsParameters: Parameterizable {
    var clientID: String?
    var clientSecret: String?

    let grantType = "client_credentials"

    public var asParameters: Parameters {
        guard
            let clientID = clientID,
            let clientSecret = clientSecret else {
                return [:]
        }

        return [
            "client_id": clientID,
            "client_secret": clientSecret,
            "grant_type": grantType
        ]
    }
}

// MARK: - -----------------------
// MARK: - UserDefaults
// MARK: - UDCreateAuditParameters
class UDCreateAuditParameters<T: Parameterizable & Codable & NSObject>: NSObject, Codable, Parameterizable {
    var localID: String = ""
    var auditType: String = ""
    var platform: String = "" //iOS
    var application: String = ""
    var source: UDSource?
    var transaction: UDTransaction<T>?
    var location: UDLocation?

    enum CodingKeys: String, CodingKey {
        case localID
        case auditType
        case platform
        case application
        case source
        case transaction
        case location
    }

    public var asParameters: Parameters {
        return [
            "type_audit": auditType,
            "platform": platform,
            "application": application,
            "source": source?.asParameters,
            "transaction": transaction?.asParameters,
            "location": location?.asParameters
        ]
    }
}

// MARK: - Source
public class UDSource: NSObject, Codable, Parameterizable {
    var trustID: String = ""
    var appName: String = ""
    var bundleID: String = ""
    var connectionType: String = ""
    var connectionName: String = ""
    var appVersion: String = ""
    var deviceName: String = ""
    var osVersion: String = ""
    var os: String = ""

    public var asParameters: Parameters {
        return [
            "trust_id": trustID,
            "app_name": appName,
            "bundle_id": bundleID,
            "os": os,
            "os_version": osVersion ,
            "device_name": deviceName,
            "connection_type": connectionType,
            "connection_name": connectionName,
            "version_app": appVersion
        ]
    }
}

// MARK: - Transaction
class UDTransaction<T: Parameterizable & Codable & NSObject>: NSObject, Codable, Parameterizable {
    var type: String = ""
    var result: String = ""
    var timestamp: Int = 1
    var method: String = ""
    var operation: String = ""
    var resultObject: T?

    public var asParameters: Parameters {
        return [
            "type": type,
            "result": result,
            "timestamp": timestamp,
            "method": method,
            "operation": operation,
            "result_object": resultObject?.asParameters
        ]
    }
}

// MARK: - Location
public class UDLocation: NSObject, Codable, Parameterizable {
    var latitude: String = ""
    var longitude: String = ""

    public var asParameters: Parameters {
        return [
            "lat_geo": latitude,
            "lon_geo": longitude,
        ]
    }
}
