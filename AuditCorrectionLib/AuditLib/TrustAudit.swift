//
//  TrustAudit.swift
//  TrustAudit
//
//  Created by Kevin Torres on 8/14/19.
//  Copyright © 2019 Kevin Torres. All rights reserved.
//

import Alamofire
import CoreTelephony
import RealmSwift

// MARK: - AuditDelegate
public protocol AuditDelegate: AnyObject {
    func onCreateAuditResponse()
    func onCreateAuditSuccess(responseData: CreateAuditResponse)
    func onCreateAuditFailure()
}

// MARK: - Environment
public enum Environment: String {
    case prod
    case test
}

// MARK: - TrustAudit
public class TrustAudit {
    // MARK: - UserDefaults
    let ud = UserDefaults.standard
    let jsonEcoder = JSONEncoder()

    // MARK: - APIManager
    private lazy var apiManager: APIManagerProtocol = {
        let apiManager = APIManager()
        apiManager.managerOutput = self
        return apiManager
    }()

    // MARK: - ClientCredentialsManager
    lazy var clientCredentialsManager: AuditClientCredentialsManagerProtocol = {
        let clientCredentialsDataManager = ClientCredentialsManager(serviceName: TrustAudit.serviceName, accessGroup: TrustAudit.accessGroup)

        clientCredentialsDataManager.managerOutput = self
        return clientCredentialsDataManager
    }()

    // MARK: - auditLocalManager
    private lazy var auditLocalManager: AuditLocalManagerProtocol = {
        let auditLocalManager = AuditLocalManager()
        return auditLocalManager
    }()

    // MARK: - Delegates
    public weak var auditDelegate: AuditDelegate?

    public var sendDeviceInfoCompletionHandler: ((ResponseStatusT) -> Void)?

    // MARK: - Private Init
    private init() {}

    static var trustID: String {
        return UserDefaults.standard.string(forKey: "trustID") ?? "ERROR"
    }

    static var currentEnvironment: String {
        return UserDefaults.standard.string(forKey: "currentEnvironment") ?? "prod"
    }

    // MARK: - Shared keychain values
    static var accessGroup: String {
        return UserDefaults.standard.string(forKey: "accessGroup") ?? ""
    }

    static var serviceName: String {
        return UserDefaults.standard.string(forKey: "serviceName") ?? Bundle.main.bundleIdentifier ?? "SwiftKeychainWrapper"
    }

    private static var trustAudit: TrustAudit = {
        return TrustAudit()
    }()

    // MARK: - Shared instance
    public static var shared: TrustAudit {
        return trustAudit
    }

    private static var credentials: String?
}

// MARK: - Public Methods
extension TrustAudit {
    public func set(serviceName: String, accessGroup: String) {
        UserDefaults.standard.set(serviceName, forKey: "serviceName")
        UserDefaults.standard.set(accessGroup, forKey: "accessGroup")
    }

    public func set(currentEnvironment: Environment) {
        UserDefaults.standard.set(currentEnvironment.rawValue, forKey: "currentEnvironment")
    }

    public func getCurrentEnvironment() -> String {
        return UserDefaults.standard.string(forKey: "currentEnvironment") ?? "Check Lib"
    }

    public func createAuditClientCredentials(clientID: String , clientSecret: String) {
        let parameters = AuditClientCredentialsParameters(clientID: clientID, clientSecret: clientSecret)

        apiManager.getClientCredentials(with: parameters)
    }

    public func setTrustID(trustID: String){
        UserDefaults.standard.set(trustID, forKey: "trustID")
    }
}

// MARK: - Create Audit - Realm
extension TrustAudit {
    public func createAudit(trustID: String,
                            connectionType: String,
                            connectionName: String,
                            type: String,
                            result: String,
                            method: String,
                            operation: String) {

        let auditObject = createAuditObject(
            trustID: trustID,
            connectionType: connectionType,
            connectionName: connectionName,
            type: type,
            result: result,
            method: method,
            operation: operation
        )

        print("Audit object parameters: \(auditObject)")

        guard let auditParameters = createAuditParameters(using: auditObject) else { return }

        auditLocalManager.add(audit: auditObject, completion: nil)
        apiManager.createAudit(with: auditParameters)
    }

    private func createAuditParameters(using auditObject: AuditObject) -> AuditParameters? {
        guard
            let objectSource = auditObject.source,
            let objectTransaction = auditObject.transaction,
            let objectLocation = auditObject.location else { return nil }

        let auditParameter = AuditParameters()
        auditParameter.localID = auditObject.localID
        auditParameter.auditType = auditObject.auditType
        auditParameter.platform = auditObject.platform
        auditParameter.application = auditObject.application

        let auditSource = Source()
        auditSource.trustID = objectSource.trustID
        auditSource.appName = objectSource.appName
        auditSource.bundleID = objectSource.bundleID
        auditSource.connectionType = objectSource.connectionType
        auditSource.connectionName = objectSource.connectionName
        auditSource.appVersion = objectSource.appVersion
        auditSource.deviceName = objectSource.deviceName
        auditSource.osVersion = objectSource.osVersion
        auditSource.os = objectSource.os

        auditParameter.source = auditSource

        let auditTransaction = Transaction()
        auditTransaction.type = objectTransaction.type
        auditTransaction.result = objectTransaction.result
        auditTransaction.timestamp = objectTransaction.timestamp
        auditTransaction.method = objectTransaction.method
        auditTransaction.operation = objectTransaction.operation

        auditParameter.transaction = auditTransaction

        let auditLocation = Location()
        auditLocation.latitude = objectLocation.latitude
        auditLocation.longitude = objectLocation.longitude

        auditParameter.location = auditLocation
        return auditParameter
    }

    // MARK: - Generate Audit Parameters
    private func createAuditObject(trustID: String,
                           connectionType: String,
                           connectionName: String,
                           type: String,
                           result: String,
                           method: String,
                           operation: String) -> AuditObject {
        let auditParameters = AuditObject()

        let sourceParameters = createSourceParameters(trustID: trustID, connectionType: connectionType, connectionName: connectionName)
        let transactionParameters = createTransactionParameters(type: type, result: result, method: method, operation: operation)
        let locationParameters = createLocationParameters()

        // BODY
        auditParameters.localID = UUID().uuidString
        auditParameters.auditType = "trust identify"
        auditParameters.platform = SourceDataManager.getOS() ?? ""
        auditParameters.application = SourceDataManager.getAppName() ?? ""
        auditParameters.source = sourceParameters
        auditParameters.transaction = transactionParameters
        auditParameters.location = locationParameters

        return auditParameters
    }

    // MARK: - Function create source parameters
    private func createSourceParameters(trustID: String,
                                        connectionType: String,
                                        connectionName: String) -> AuditSource {
        let sourceParameters = AuditSource()

        sourceParameters.trustID = trustID
        sourceParameters.appName =  SourceDataManager.getAppName() ?? ""
        sourceParameters.bundleID = SourceDataManager.getBundleID() ?? ""
        sourceParameters.connectionType = connectionType
        sourceParameters.connectionName = connectionName
        sourceParameters.appVersion = SourceDataManager.getAppVersion() ?? ""
        sourceParameters.os = SourceDataManager.getOS() ?? ""
        sourceParameters.deviceName = SourceDataManager.getDeviceName() ?? ""
        sourceParameters.osVersion = SourceDataManager.getOSVersion() ?? ""

        return sourceParameters
    }

    // MARK: - Function create transaction parameters
    private func createTransactionParameters(type: String,
                                             result: String,
                                             method: String,
                                             operation: String) -> AuditTransaction {
        let transactionParameters = AuditTransaction()

        transactionParameters.type = type
        transactionParameters.result = result
        transactionParameters.timestamp = TransactionDataManager.getTimestamp() ?? 1
        transactionParameters.method = method
        transactionParameters.operation = operation

        return transactionParameters
    }

    // MARK: - Function create location parameters
    private func createLocationParameters() -> AuditLocation {
        let locationParameters = AuditLocation()

        let location = BodyDataManager()
        let auditLatitude = String(location.getLat())
        let auditLongitude = String(location.getLng())

        locationParameters.latitude = auditLatitude
        locationParameters.longitude = auditLongitude

        return locationParameters
    }

    // MARK: - Audit Realm management
    func checkAuditEnqueue() -> Bool {
        print("Check audit enqueue count: \(getAll().count)")
        return getAll().count >= 1 ? true : false
    }

    func sendAuditEnqueue() { // Create enqueue audit
        guard
            let firstAuditInQueue = getFirstItem(),
            let auditParameters = createAuditParameters(using: firstAuditInQueue) else { return }

        apiManager.createAudit(with: auditParameters)
    }

    func deleteAuditById(currentLocalID: String) {
        guard let item = auditLocalManager.getAuditBy(id: currentLocalID) else { return }
        auditLocalManager.delete(item: item)
    }

    func save(audit: AuditObject) {
        auditLocalManager.add(audit: audit, completion: nil)
    }

    func getAll() -> Results<AuditObject> {
        auditLocalManager.getAllAudits()
    }

    func getFirstItem() -> AuditObject? {
        auditLocalManager.getFirstAudit()
    }
}

// MARK: - Create Audit User Defaults
extension TrustAudit {
    public func createAudit<T: Parameterizable & Codable & NSObject>(trustID: String,
                                                                     connectionType: String,
                                                                     connectionName: String,
                                                                     type: String,
                                                                     result: String,
                                                                     method: String,
                                                                     operation: String,
                                                                     resultObject: T?) {
        let auditParameters = createUDParameters(
            trustID: trustID,
            connectionType: connectionType,
            connectionName: connectionName,
            type: type,
            result: result,
            method: method,
            operation: operation,
            resultObject: resultObject
        )

        saveUD(audit: auditParameters)
        apiManager.udCreateAudit(with: auditParameters)
    }

    // MARK: - Generate Audit Parameters
    private func createUDParameters<T: Parameterizable & Codable & NSObject>(trustID: String,
                                                                     connectionType: String,
                                                                     connectionName: String,
                                                                     type: String,
                                                                     result: String,
                                                                     method: String,
                                                                     operation: String,
                                                                     resultObject: T?) -> UDCreateAuditParameters<T> {
        let auditParameters = UDCreateAuditParameters<T>()

        let sourceParameters = createUDSourceParameters(trustID: trustID, connectionType: connectionType, connectionName: connectionName)
        let transactionParameters = createUDTransactionParameters(type: type, result: result, method: method, operation: operation, resultObject: resultObject)
        let locationParameters = createUDLocationParameters()

        // BODY
        auditParameters.localID = UUID().uuidString
        auditParameters.auditType = "trust identify"
        auditParameters.platform = SourceDataManager.getOS() ?? ""
        auditParameters.application = SourceDataManager.getAppName() ?? ""
        auditParameters.source = sourceParameters
        auditParameters.transaction = transactionParameters
        auditParameters.location = locationParameters

        return auditParameters
    }

    // MARK: - Function create SOURCE parameters
    private func createUDSourceParameters(trustID: String,
                                          connectionType: String,
                                          connectionName: String) -> UDSource {
        let sourceParameters = UDSource()

        sourceParameters.trustID = trustID
        sourceParameters.appName =  SourceDataManager.getAppName() ?? ""
        sourceParameters.bundleID = SourceDataManager.getBundleID() ?? ""
        sourceParameters.connectionType = connectionType
        sourceParameters.connectionName = connectionName
        sourceParameters.appVersion = SourceDataManager.getAppVersion() ?? ""
        sourceParameters.os = SourceDataManager.getOS() ?? ""
        sourceParameters.deviceName = SourceDataManager.getDeviceName() ?? ""
        sourceParameters.osVersion = SourceDataManager.getOSVersion() ?? ""

        return sourceParameters
    }

    // MARK: - Function create TRANSACTION parameters
    private func createUDTransactionParameters<T: Parameterizable>(type: String,
                                                                   result: String,
                                                                   method: String,
                                                                   operation: String,
                                                                   resultObject: T?) -> UDTransaction<T> {
        let transactionParameters = UDTransaction<T>()

        transactionParameters.type = type
        transactionParameters.result = result
        transactionParameters.timestamp = TransactionDataManager.getTimestamp() ?? 1
        transactionParameters.method = method
        transactionParameters.operation = operation

        transactionParameters.resultObject = resultObject

        return transactionParameters
    }

    // MARK: - Function create LOCATION parameters
    private func createUDLocationParameters() -> UDLocation {
        let locationParameters = UDLocation()

        let location = BodyDataManager()
        let auditLatitude = String(location.getLat())
        let auditLongitude = String(location.getLng())

        locationParameters.latitude = auditLatitude
        locationParameters.longitude = auditLongitude

        return locationParameters
    }

    // MARK: - Audit Management User Default
    func saveUD<T: Parameterizable & Codable & NSObject>(audit: UDCreateAuditParameters<T>) {
        do { // Save a new audit in array
            if let decoded = ud.data(forKey: "audits") {
                let dataObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as! Data
                var jsonDec = try JSONDecoder().decode([UDCreateAuditParameters<T>].self, from: dataObject)

                jsonDec.append(audit)
                let encoder = try jsonEcoder.encode(jsonDec)
                let auditData = try NSKeyedArchiver.archivedData(withRootObject: encoder, requiringSecureCoding: false)
                ud.set(auditData, forKey: "audits")
            } else { // No audit saved in ud
                var audits: [UDCreateAuditParameters<T>]? = []
                audits?.append(audit)

                let encoder = try jsonEcoder.encode(audits)
                let auditData = try NSKeyedArchiver.archivedData(withRootObject: encoder, requiringSecureCoding: false)
                ud.set(auditData, forKey: "audits")
            }
        } catch let error {
            print("Found Error: ", error)
        }
    }

    func getUDAudits<T: NSObject & Codable & Parameterizable>(type: T?) -> [UDCreateAuditParameters<T>] {
        do {
            if let decoded = ud.data(forKey: "audits") {
                let dataObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as! Data

                let jsonDec = try JSONDecoder().decode([UDCreateAuditParameters<T>].self, from: dataObject)
                return jsonDec
            }
        } catch let error {
            print("Found Error: ", error)
        }
        return []
    }

    func onCreateUDAudit<T: NSObject & Codable & Parameterizable>(parameters: UDCreateAuditParameters<T>) {
        apiManager.udCreateAudit(with: parameters)
    }

    func deleteUDAuditById<T: NSObject & Codable & Parameterizable>(currentLocalID: String, parameters: UDCreateAuditParameters<T>) {
        do {
            if let decoded = ud.data(forKey: "audits") {
                let dataObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as! Data

                let jsonDec = try JSONDecoder().decode([UDCreateAuditParameters<T>].self, from: dataObject)
                let auditWithRemovedItem = jsonDec.filter{ $0.localID != currentLocalID }
                guard auditWithRemovedItem.count != 0 else {
                    ud.removeObject(forKey: "audits")
                    print("Audits en queue deleted")
                    return
                }
                let encoder = try jsonEcoder.encode(auditWithRemovedItem)
                let auditData = try NSKeyedArchiver.archivedData(withRootObject: encoder, requiringSecureCoding: false)
                ud.set(auditData, forKey: "audits")
                print("Audit: id", currentLocalID, " deleted")
            }
        } catch let error {
            print("Found Error: ", error)
        }
    }

    func checkUDAuditEnqueue<T: NSObject & Codable & Parameterizable>(parameters: UDCreateAuditParameters<T>) -> Bool {
        do { // Save a new audit in array
            if let decoded = ud.data(forKey: "audits") {
                let dataObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as! Data
                let jsonDec = try JSONDecoder().decode([UDCreateAuditParameters<T>].self, from: dataObject)
                guard jsonDec.count != 0 else { return false }
                return true
            } else { // No audit saved in ud
                return false
            }
        } catch let error {
            print("Found Error: ", error)
        }
        return false
    }

    func getFirstUDAuditEnqueue<T: NSObject & Codable & Parameterizable>(parameters: UDCreateAuditParameters<T>) -> UDCreateAuditParameters<T>?  {
        do {
            if let decoded = ud.data(forKey: "audits") {
                let dataObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as! Data

                let jsonDec = try JSONDecoder().decode([UDCreateAuditParameters<T>].self, from: dataObject)
                return jsonDec[0]
            }
        } catch let error {
            print("Found Error: ", error)
        }
        return nil
    }

    func sendUDAuditEnqueue<T: NSObject & Codable & Parameterizable>(parameters: UDCreateAuditParameters<T>) {
        guard let item = getFirstUDAuditEnqueue(parameters: parameters) else { return }
        apiManager.udCreateAudit(with: item)
    }
}

// MARK: - APIManagerOutputProtocol
extension TrustAudit: APIManagerOutputProtocol {
    // MARK: - ClientCredentials
    func onClientCredentialsResponse() {}

    func onClientCredentialsSuccess(responseData: AuditClientCredentials) {
        clientCredentialsManager.save(clientCredentials: responseData)
    }

    func onClientCredentialsFailure() {}

    // MARK: - Create Audit
    func onCreateAuditResponse() {
        auditDelegate?.onCreateAuditResponse()
    }

    func onCreateAuditSuccess(responseData: CreateAuditResponse, parameters: AuditParameters) {
        auditDelegate?.onCreateAuditSuccess(responseData: responseData)
        if responseData.message != nil {
            deleteAuditById(currentLocalID: parameters.localID)
            if checkAuditEnqueue() {
                sendAuditEnqueue()
            }
        }
    }

    func onCreateAuditFailure() {
        auditDelegate?.onCreateAuditFailure()
    }

    // MARK: - UD Create Audit
    func onCreateUDAuditResponse() {
        auditDelegate?.onCreateAuditResponse()
    }

    func onCreateUDAuditSuccess<T>(responseData: CreateAuditResponse, parameters: UDCreateAuditParameters<T>) where T: Parameterizable {
        auditDelegate?.onCreateAuditSuccess(responseData: responseData)
        if responseData.message != nil {
            deleteUDAuditById(currentLocalID: parameters.localID, parameters: parameters)
            if checkUDAuditEnqueue(parameters: parameters) {
                sendUDAuditEnqueue(parameters: parameters)
            } else { print("Done") }
        }
    }

    func onCreateUDAuditFailure() {
        auditDelegate?.onCreateAuditFailure()
    }
}

// MARK: - AuditClientCredentialsManagerOutputProtocol
extension TrustAudit: AuditClientCredentialsManagerOutputProtocol {
    func onClientCredentialsSaved(savedClientCredentials: AuditClientCredentials) {}
}
