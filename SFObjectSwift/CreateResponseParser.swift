//
//  CreateResponseParser.swift
//  SFObjectSwift
//
//  Created by MiyakeAkira on 2015/07/05.
//  Copyright (c) 2015年 Miyake Akira. All rights reserved.
//

import Foundation
import Result
import SwiftyJSON

public class CreateResponseParser: ResponseParserProtocol {
    
    public typealias T = Id
    
    public init() {}
    
    public func parse(data: AnyObject) -> Result<T, NSError> {
        typealias CreateResult = Result<T, NSError>
        
        let json = JSON(data)
        
        if let id = json["id"].string {
            return CreateResult.success(id)
        } else {
            // TODO: Add error code
            let error = NSError(domain: ErrorDomain, code: 0, userInfo: nil)
            return CreateResult.failure(error)
        }
    }
    
}