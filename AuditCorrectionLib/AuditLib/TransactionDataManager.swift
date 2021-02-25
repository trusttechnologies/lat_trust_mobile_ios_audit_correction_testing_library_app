//
//  TransactionDataManager.swift
//  TrustAudit
//
//  Created by Kevin Torres on 9/23/19.
//  Copyright © 2019 Kevin Torres. All rights reserved.
//

import Foundation

// MARK: - TransactionDataManagerProtocol
protocol TransactionDataManagerProtocol: NSObjectProtocol {
    static func getTimestamp() -> Int?
}

// MARK: - TransactionDataManager
public class TransactionDataManager: NSObject, TransactionDataManagerProtocol {
    // MARK: - Get time stamp
    static func getTimestamp() -> Int? {
        var tval = timeval()
        if gettimeofday(&tval, nil) == 0 {
            let secondsSince1970 = Int(tval.tv_sec)
            return secondsSince1970
        }
        return 0
    }
}
