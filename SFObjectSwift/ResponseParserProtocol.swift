//
//  ResponseParserProtocol.swift
//  SFObjectSwift
//
//  Created by MiyakeAkira on 2015/07/05.
//  Copyright (c) 2015年 Miyake Akira. All rights reserved.
//

import Foundation
import Result

public protocol ResponseParserProtocol {
    
    typealias T
    
    func parse(data: AnyObject) -> Result<T, NSError>
    
}