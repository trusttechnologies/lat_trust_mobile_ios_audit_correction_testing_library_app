//
//  ViewController.swift
//  AuditCorrectionLib
//
//  Created by Kevin Torres on 9/5/19.
//  Copyright © 2019 Kevin Torres. All rights reserved.
//

import UIKit
import TrustDeviceInfo
import CoreLocation
import Alamofire

class ViewController: UIViewController {

    let locationManager = CLLocationManager()
    let savedTrustId = Identify.shared.getTrustID()

    @IBOutlet weak var auditsCount: UILabel!
    
    @IBAction func createOneAudit(_ sender: Any) {
        let savedTrustId = Identify.shared.getTrustID()

        createLoginAudit(cant:1, trustID: savedTrustId ?? "")
    }
    
    @IBAction func createThreeAudits(_ sender: Any) {
        let savedTrustId = Identify.shared.getTrustID()

        createLoginAudit(cant:3, trustID: savedTrustId ?? "")
    }
    
    @IBAction func sendAudit(_ sender: Any) {
        if TrustAudit.shared.checkAuditEnqueue() {
            TrustAudit.shared.sendAuditEnqueue()
        }
    }
    
    @IBAction func createDirectAudit(_ sender: Any) {
        createAudit()
    }

    @IBAction func refreshBtn(_ sender: Any) {
        auditsCount.text = String(TrustAudit.shared.getAll().count)
    }
}

extension ViewController {
    func createAudit() {
        // MARK: - Result obj audit
//        let objectResult = AuditObjectResult()
//        objectResult.audit = "1"
//        objectResult.dni = "11.111.111-1"
//        objectResult.name = "Test User"
//        objectResult.validate = "Success"
//
//        TrustAudit.shared.createAudit(trustID: savedTrustId ?? "",
//                                      connectionType: "No connection type TEST",
//                                      connectionName: "No connection name TEST",
//                                      type: "trust identify",
//                                      result: "success",
//                                      method: "createLoginAudit",
//                                      operation: "login",
//                                      resultObject: objectResult)

        // MARK: - Normal audit
        TrustAudit.shared.createAudit(
            trustID: savedTrustId ?? "",
            connectionType: "No connection type TEST",
            connectionName: "No connection name TEST",
            type: "trust identify",
            result: "success",
            method: "createLoginAudit",
            operation: "login"
        )
    }
}

extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
//        locationManager.requestWhenInUseAuthorization()
        auditsCount.text = String(TrustAudit.shared.getAll().count)
    }

    func createLoginAudit(cant:Int, trustID:String) {
        for n in 1...cant{
//            let auditParameters = TrustAudit.shared.createAuditObject(
//                trustID: trustID,
//                connectionType: "connectionType",
//                connectionName: "connectionName",
//                type: "trust identify",
//                result: "success777",
//                method: "method testing",
//                operation: "operation testing"
//            )
//            TrustAudit.shared.save(audit: auditParameters)
        }
        auditsCount.text = String(TrustAudit.shared.getAll().count)
    }
}

// MARK: - ObjectResult
class AuditObjectResult: NSObject, Parameterizable, Codable {
    var audit: String = ""
    var dni: String = ""
    var name: String = ""
    var validate: String = ""

    enum CodingKeys: String, CodingKey {
        case audit
        case dni
        case name
        case validate
    }

    public var asParameters: Parameters {
        return [
            "audit": audit,
            "dni": dni,
            "name": name,
            "validate": validate
        ]
    }
}

