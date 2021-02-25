//
//  SourceDatamanager.swift
//  TrustAudit
//
//  Created by Kevin Torres on 9/23/19.
//  Copyright © 2019 Kevin Torres. All rights reserved.
//

import UIKit
import Foundation
import Darwin

// MARK: - SourceDataManagerProtocol
protocol SourceDataManagerProtocol: NSObjectProtocol {
    static func getAppName() -> String?
    static func getOSVersion() -> String?
    static func getAppVersion() -> String?
    static func getBundleID() -> String?
    static func getDeviceName() -> String?
    static func getOS() -> String?
}

// MARK: - SourceDataManager
public class SourceDataManager: NSObject, SourceDataManagerProtocol {
    // MARK: - Get app name
    static func getAppName() -> String? {
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
        return appName
    }

    // MARK: - Get OS version
    static func getOSVersion() -> String? {
        if #available(iOS 9.0, *) {
            let systemVersion = UIDevice.current.systemVersion
            return systemVersion
        }
        return "0"
    }

    // MARK: - Get app version
    static func getAppVersion() -> String? {
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "0"
        }
        return appVersion
    }

    // MARK: - Get bundleID
    static func getBundleID() -> String? {
        guard let bundleID = Bundle.main.bundleIdentifier else {
            return "0"
        }
        return bundleID
    }

    // MARK: - Get device name
    static func getDeviceName() -> String? {
        if #available(iOS 9.0, *) {
            let name = UIDevice.current.name
            return name
        }
        return "0"
    }

    // MARK: - Get Operating System
    static func getOS() -> String? {
        return "IOS"
    }
}
