//
//  QueryResponseParser.swift
//  SFObjectSwift
//
//  Created by MiyakeAkira on 2015/07/05.
//  Copyright (c) 2015年 Miyake Akira. All rights reserved.
//

import Foundation
import Result

public class QueryResponseParser<Object>: ResponseParserProtocol {
    
    public typealias T = [Object]
    
    public init() {}
    
    public func parse(data: AnyObject) -> Result<T, NSError> {
        typealias QueryResult = Result<T, NSError>
        
        // TODO: Add error code
        let error = NSError(domain: ErrorDomain, code: 0, userInfo: nil)
        return Result.failure(error)
    }
    
}