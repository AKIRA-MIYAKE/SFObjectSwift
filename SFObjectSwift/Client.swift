//
//  Client.swift
//  SFObjectSwift
//
//  Created by MiyakeAkira on 2015/07/05.
//  Copyright (c) 2015年 Miyake Akira. All rights reserved.
//

import Foundation
import Alamofire
import Result
import SFOAuth
import SwiftyJSON

public typealias Id = String

public class Client<T: SObjectProtocol> {
    
    // MARK: - let
    
    private let createResponseParser: CreateResponseParser
    private let queryResponseParser: QueryResponseParser<T>
    
    
    // MARK: - Initialize
    
    public init(queryResponseParser: QueryResponseParser<T>) {
        self.createResponseParser = CreateResponseParser()
        self.queryResponseParser = queryResponseParser
    }
    
    public init(createResponseParser: CreateResponseParser, queryResponseParser: QueryResponseParser<T>) {
        self.createResponseParser = createResponseParser
        self.queryResponseParser = queryResponseParser
    }
    
    
    // MARK: - Public method
    
    public func create(sObject: T, _ completion: Result<Id, NSError> -> Void) {
        typealias CreateResut = Result<Id, NSError>
        
        if let credentail = OAuth.credentialStore.credential {
            getCreateRequest(sObject, credential: credentail)
                .responseJSON { (request, response, data, error) -> Void in
                    if let error = error {
                        let result = CreateResut.failure(error)
                        completion(result)
                    } else {
                        if let data: AnyObject = data {
                            if self.verifySessionId(data) {
                                let result = self.createResponseParser.parse(data)
                                completion(result)
                            } else {
                                OAuth.refresh { result in
                                    switch result {
                                    case .Success(let box):
                                        self.create(sObject, completion)
                                    case .Failure(let box):
                                        let result = CreateResut.failure(box.value)
                                        completion(result)
                                    }
                                }
                            }
                        } else {
                            // TODO: Add error code
                            let error = NSError(domain: ErrorDomain, code: 0, userInfo: nil)
                            let result = CreateResut.failure(error)
                            completion(result)
                        }
                    }
                }
        } else {
            // TODO: Add error code
            let error = NSError(domain: ErrorDomain, code: 0, userInfo: nil)
            let result = CreateResut.failure(error)
            completion(result)
        }
    }
    
    public func query(#options: String?, _ completion: Result<[T], NSError> -> Void) {
        typealias QueryResult = Result<[T], NSError>
        
        if let credential = OAuth.credentialStore.credential {
            getQueryRequest(options: options, credential: credential)
                .responseJSON { (request, response, data, error) -> Void in
                    if let error = error {
                        let result = QueryResult.failure(error)
                        completion(result)
                    } else {
                        if let data: AnyObject = data {
                            if self.verifySessionId(data) {
                                let result = self.queryResponseParser.parse(data)
                                completion(result)
                            } else {
                                OAuth.refresh { result in
                                    switch result {
                                    case .Success(let box):
                                        self.query(options: options, completion)
                                    case .Failure(let box):
                                        let result = QueryResult.failure(box.value)
                                        completion(result)
                                    }
                                }
                            }
                        } else {
                            // TODO: Add error code
                            let error = NSError(domain: ErrorDomain, code: 0, userInfo: nil)
                            let result = QueryResult.failure(error)
                            completion(result)
                        }
                    }
                }
        } else {
            // TODO: Add error code
            let error = NSError(domain: ErrorDomain, code: 0, userInfo: nil)
            let result = QueryResult.failure(error)
            completion(result)
        }
    }
    
    
    // MARK: - Private method
    
    private func verifySessionId(data: AnyObject) -> Bool {
        let json = JSON(data)
        
        if let errorCode = json[0]["errorCode"].string {
            if errorCode == "INVALID_SESSION_ID" {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    private func getCreateRequest(sObject:T, credential: Credential) -> Alamofire.Request {
        let manager = Alamofire.Manager.sharedInstance
        manager.session.configuration.HTTPAdditionalHeaders = [
            "Authorization": "Bearer \(credential.accessToken)"
        ]
        
        let URLString = "\(credential.instanceURL)/services/data/\(Service.appVersion)/sobjects/\(T.AppName)"
        let parameters = sObject.toDictionary()
        
        return Alamofire.request(.POST, URLString, parameters: parameters, encoding: .JSON)
    }
    
    private func getQueryRequest(#options: String?, credential: Credential) -> Alamofire.Request {
        let manager = Alamofire.Manager.sharedInstance
        manager.session.configuration.HTTPAdditionalHeaders = [
            "Authorization": "Bearer \(credential.accessToken)"
        ]
        
        let URLString = "\(credential.instanceURL)/services/data/\(Service.appVersion)/query"
        
        let fields = ",".join(T.AppFieldNames)
        
        var q = "SELECT \(fields) FROM \(T.AppName)"
        
        if let options = options {
            q = q + " \(options)"
        }
        
        let parameters: [String: AnyObject] = ["q": q]
        
        return Alamofire.request(.GET, URLString, parameters: parameters)
    }
    
}