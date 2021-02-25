//
//  AuditLocalManager.swift
//  AuditCorrectionLib
//
//  Created by Kevin Torres on 20-02-21.
//  Copyright © 2021 Kevin Torres. All rights reserved.
//

import Foundation
import RealmSwift

// MARK: - AuditLocalManagerProtocol
protocol AuditLocalManagerProtocol: AnyObject {
    func add(audit: AuditObject, completion: CompletionHandler)
    func getFirstAudit() -> AuditObject?
    func getAllAudits() -> Results<AuditObject>
    func getAuditBy(id: String) -> RealmRepo<AuditObject>.Item?
    func delete(item: RealmRepo<AuditObject>.Item)
    func deleteAllAudits(completion: CompletionHandler)
}

// MARK: - AuditLocalManager
final class AuditLocalManager {}

// MARK: - AuditLocalManagerProtocol
extension AuditLocalManager: AuditLocalManagerProtocol {
    func add(audit: AuditObject, completion: CompletionHandler) { RealmRepo<AuditObject>.add(item: audit, completion: completion) }

    func getFirstAudit() -> AuditObject? { RealmRepo<AuditObject>.getFirst() }
    func getAllAudits() -> Results<AuditObject> { RealmRepo<AuditObject>.getAll() }
    func getAuditBy(id: String) -> RealmRepo<AuditObject>.Item? { RealmRepo<AuditObject>.getBy(key: "localID", value: id) }

    func delete(item: RealmRepo<AuditObject>.Item) { RealmRepo<AuditObject>.delete(item: item) }
    func deleteAllAudits(completion: CompletionHandler) { RealmRepo<AuditObject>.deleteAll(completion: completion) }
}
