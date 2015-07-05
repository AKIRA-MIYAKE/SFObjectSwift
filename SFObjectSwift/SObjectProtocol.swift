//
//  SObjectProtocol.swift
//  SFObjectSwift
//
//  Created by MiyakeAkira on 2015/07/05.
//  Copyright (c) 2015年 Miyake Akira. All rights reserved.
//

import Foundation

public protocol SObjectProtocol {
    
    // MARK: - Static variables
    
    static var AppName: String { get }
    static var AppFieldsNames: [String] { get }
    
    
    // MARK: - Method
    
    func toDictionary() -> [String: AnyObject]
    
}