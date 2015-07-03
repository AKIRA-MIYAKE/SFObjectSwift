//
//  CredentialStoreProtocol.swift
//  SFOAuthSwift
//
//  Created by MiyakeAkira on 2015/07/03.
//  Copyright (c) 2015年 Miyake Akira. All rights reserved.
//

import Foundation

public protocol CredentialStoreProtocol {
    
    var credential: Credential? { get set }
    
}