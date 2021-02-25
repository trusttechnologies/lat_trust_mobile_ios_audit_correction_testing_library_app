//
//  Extensions.swift
//  TrustAudit
//
//  Created by Kevin Torres on 8/14/19.
//  Copyright © 2019 Kevin Torres. All rights reserved.
//

import Alamofire
import Foundation

// MARK: -  Typealias
typealias CompletionHandler = (() -> Void)?
typealias SuccessHandler<T> = ((T) -> Void)?

// MARK: - App Strings
extension String {
    static let empty = ""
    static let zero = "0"
    static let appLocale = "es_CL"
    static let yyyyMMddHHmmss = "yyyy-MM-dd HH:mm:ss"
}

extension String {
    var unescaped: String {
        let entities = ["\0", "\t", "\n", "\r", "\"", "\'", "\\"]
        var current = self
        for entity in entities {
            let descriptionCharacters = entity.debugDescription.dropFirst().dropLast()
            let description = String(descriptionCharacters)
            current = current.replacingOccurrences(of: description, with: entity)
        }
        return current
    }
}


// MARK: Extension Bundle
extension Bundle {
    var versionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }

    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
            object(forInfoDictionaryKey: "CFBundleName") as? String
    }

    var appVersion: String {
        return "\(versionNumber ?? .zero).\(buildNumber ?? .zero)"
    }
}

// MARK: - CustomStringConvertible
extension CustomStringConvertible {
    public var description: String {
        var description: String = .empty
        let selfMirror = Mirror(reflecting: self)

        for child in selfMirror.children {
            if let propertyName = child.label {
                description += "\(propertyName): \(child.value)\n"
            }
        }

        return description
    }
}

// MARK: - Extension Date
extension Date {
    func toString(with format: String) -> String {
        let dateFormatter = DateFormatter()

        dateFormatter.locale = Locale(identifier: .appLocale)
        dateFormatter.dateFormat = format

        return dateFormatter.string(from: self)
    }
}

// MARK: - Parameterizable
public protocol Parameterizable {
    var asParameters: Parameters {get}
}
