//
//  RealmRepo.swift
//  TrustAudit
//
//  Created by Kevin Torres on 9/23/19.
//  Copyright © 2019 Kevin Torres. All rights reserved.
//

import RealmSwift

// MARK: - Class RealmRepo
class RealmRepo<T: Object>: Addable, Deletable, Gettable {
    typealias Item = T
}

// MARK: - PrimaryKeyable
protocol PrimaryKeyable: AnyObject {
    associatedtype KeyType

    static var primaryKeyIdentifier: String { get }
    var id: KeyType { get }
    static func primaryKey() -> String?
}

extension PrimaryKeyable {
    static var primaryKeyIdentifier: String {
        return "id"
    }
}

// MARK: - Itemable
protocol Itemable: AnyObject {
    associatedtype Item: Object
}

// MARK: - Addable
protocol Addable: Itemable {
    static func add(item: Item..., completion: CompletionHandler)
    static func add(itemList: [Item], completion: CompletionHandler)
}

extension Addable {
    static func add(item: Item..., completion: CompletionHandler = nil) {

        let realm = try! Realm()

        try! realm.write {
            item.forEach {
                realm.add($0)
            }
        }

        completion?()
    }

    static func add(itemList: [Item], completion: CompletionHandler = nil) {

        let realm = try! Realm()

        try! realm.write {
            realm.add(itemList)
        }

        completion?()
    }
}

extension Addable where Item: PrimaryKeyable {
    static func add(item: Item..., completion: CompletionHandler = nil) {

        let realm = try! Realm()

        try! realm.write {
            item.forEach {
                realm.add($0, update: .modified)
            }
        }

        completion?()
    }

    static func add(itemList: [Item], completion: CompletionHandler = nil) {

        guard !itemList.isEmpty else { return }

        let realm = try! Realm()

        try! realm.write {
            realm.add(itemList, update: .modified)
        }

        completion?()
    }
}

// MARK: - Deletable
protocol Deletable: Itemable {
    static func delete(item: Item..., completion: CompletionHandler)
    static func delete(items: [Item], completion: CompletionHandler)
    static func deleteAll(completion: CompletionHandler)
}

extension Deletable {
    static func delete(item: Item..., completion: CompletionHandler = nil) {

        let realm = try! Realm()

        try! realm.write {
            item.forEach {
                realm.delete($0)
            }
        }

        completion?()
    }

    static func delete(items: [Item], completion: CompletionHandler = nil) {

        let realm = try! Realm()

        try! realm.write {
            realm.delete(items)
        }

        completion?()
    }

    static func deleteAll(completion: CompletionHandler = nil) {

        let realm = try! Realm()

        try! realm.write {
            let objectsToDelete = realm.objects(Item.self)
            realm.delete(objectsToDelete)
        }

        completion?()
    }
}

// MARK: - Gettable
protocol Gettable: Itemable {
    static func getBy<T>(key: String, value: T) -> Item?
    static func getAllBy<T>(key: String, value: T) -> Results<Item>
    static func getFirst() -> Item?
    static func getAll() -> Results<Item>
}

extension Gettable {
    static func getBy<T>(key: String, value: T) -> Item? {

        let realm = try! Realm()

        return realm.objects(Item.self).filter("\(key) == %@", value).first
    }

    static func getAllBy<T>(key: String, value: T) -> Results<Item> {

        let realm = try! Realm()

        return realm.objects(Item.self).filter("\(key) == %@", value)
    }

    static func getFirst() -> Item? {

        let realm = try! Realm()

        return realm.objects(Item.self).first
    }

    static func getAll() -> Results<Item> {

        let realm = try! Realm()

        return realm.objects(Item.self)
    }
}
