//
//  DefaultCredentialStore.swift
//  SFOAuthSwift
//
//  Created by MiyakeAkira on 2015/07/03.
//  Copyright (c) 2015年 Miyake Akira. All rights reserved.
//

import Foundation

public class DefaultCredentialStore: CredentialStoreProtocol {
    
    // MARK: - Static let
    
    public static let key = "SalesforceOAuthCredentialKey"
    
    
    // MARK: - let
    
    private let userDefaults: NSUserDefaults
    
    
    // MARK: - Initialize
    
    init() {
        userDefaults = NSUserDefaults.standardUserDefaults()
    }
    
    
    // MARK: - Credential store protocol
    
    public var credential: Credential? {
        set {
            if let value = newValue {
                let dict = value.toDictionary()
                let data = NSKeyedArchiver.archivedDataWithRootObject(dict)
                
                userDefaults.setValue(data, forKey: DefaultCredentialStore.key)
                userDefaults.synchronize()
            }
        }
        
        get {
            return (userDefaults.valueForKey(DefaultCredentialStore.key) as? NSData)
                .flatMap({ NSKeyedUnarchiver.unarchiveObjectWithData($0) as? [String: String] })
                .flatMap({ Credential(dict: $0) })
        }
    }
    
    
    
}