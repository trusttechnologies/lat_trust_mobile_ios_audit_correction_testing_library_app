//
//  AppDelegate.swift
//  AuditCorrectionLib
//
//  Created by Kevin Torres on 9/5/19.
//  Copyright © 2019 Kevin Torres. All rights reserved.
//

import UIKit
import TrustDeviceInfo
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder {
    var window: UIWindow?
}

// MARK: - UIApplicationDelegate
extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let serviceName = "defaultServiceName"
        let accessGroup = "P896AB2AMC.trustID.appLib"
        let clientID = "adcc11078bee4ba2d7880a48c4bed02758a5f5328276b08fa14493306f1e9efb"
        let clientSecret = "1f647aab37f4a7d7a0da408015437e7a963daca43da06a7789608c319c2930bd"
        
        Identify.shared.trustDeviceInfoDelegate = self
        Identify.shared.set(serviceName: serviceName, accessGroup: accessGroup)
        Identify.shared.createClientCredentials(clientID: clientID, clientSecret: clientSecret)
        Identify.shared.enable()
        
        TrustAudit.shared.set(serviceName: serviceName, accessGroup: accessGroup)
        TrustAudit.shared.createAuditClientCredentials(clientID: clientID, clientSecret: clientSecret)


        let config = Realm.Configuration(schemaVersion: 1)
        Realm.Configuration.defaultConfiguration = config
        

        return true
    }
}

// MARK: - TrustDeviceInfoDelegate
extension AppDelegate: TrustDeviceInfoDelegate {
    func onClientCredentialsSaved(savedClientCredentials: ClientCredentials) {
        //
    }

    func onTrustIDSaved(savedTrustID: String) {
        //
    }

    func onRegisterFirebaseTokenSuccess(responseData: RegisterFirebaseTokenResponse) {
        //
    }

    func onSendDeviceInfoResponse(status: ResponseStatus) {
        //
    }
}
