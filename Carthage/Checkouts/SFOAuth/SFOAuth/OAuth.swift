//
//  OAuth.swift
//  SFOAuth
//
//  Created by MiyakeAkira on 2015/07/07.
//  Copyright (c) 2015年 Miyake Akira. All rights reserved.
//

import Foundation
import Alamofire
import OAuthSwift
import Result
import SwiftyJSON

public class OAuth {
    
    // MARK: - Static variables
    
    public static var credentialStore: CredentialStoreProtocol = DefaultCredentialStore()
    
    public static var credential: Credential? {
        return credentialStore.credential
    }
    
    public static var clientId: String = ""
    public static var clientSecret: String = ""
    public static var redirectURL: NSURL?
    
    
    // MARK: - Static method
    
    public static func authorization(
        #clientId: String,
        clientSecret: String,
        scope: [Scope],
        state: String,
        redirectURL: NSURL,
        _ completion: Result<Credential, NSError> -> Void)
    {
        typealias AuthResult = Result<Credential, NSError>
        
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectURL = redirectURL
        
        let oauth = OAuth2Swift(
            consumerKey: clientId,
            consumerSecret: clientSecret,
            authorizeUrl: AuthorizeURL,
            accessTokenUrl: AccessTokenURL,
            responseType: ResponseType)
        
        let scopeString = "+".join(scope.map({ $0.rawValue }))
        
        oauth.authorizeWithCallbackURL(
            redirectURL,
            scope: scopeString,
            state: state,
            success: { (credential, response, parameters) -> Void in
                if let accessToken = parameters[Credential.accessTokenKey] as? String,
                    let refreshToken = parameters[Credential.refreshTokenKey] as? String,
                    let instanceURL = parameters[Credential.instanceURLKey] as? String
                {
                    let credential = Credential(
                        accessToken: accessToken,
                        refreshToken: refreshToken,
                        instanceURL: instanceURL)
                    
                    self.credentialStore.credential = credential
                    
                    let result = AuthResult.success(credential)
                    completion(result)
                } else {
                    // TODO: - Add error code
                    let error = NSError(domain: ErrorDomain, code: 0, userInfo: nil)
                    let result = AuthResult.failure(error)
                    completion(result)
                }
            }) { (error) -> Void in
                let result = AuthResult.failure(error)
                completion(result)
        }
    }
    
    public static func refresh(completion: Result<Credential, NSError> -> Void) {
        typealias AuthResult = Result<Credential, NSError>
        
        if let credential = credentialStore.credential {
            let parameters: [String: AnyObject] = [
                "grant_type": "refresh_token",
                "client_id": clientId,
                "client_secret": clientSecret,
                "refresh_token": credential.refreshToken
            ]
            
            Alamofire.request(.POST, AccessTokenURL, parameters: parameters)
                .responseJSON { (request, response, data, error) -> Void in
                    if let error = error {
                        let result = AuthResult.failure(error)
                        completion(result)
                    } else {
                        if let data: AnyObject = data {
                            let json = JSON(data)
                            
                            if let accessToken = json[Credential.accessTokenKey].string,
                                let refreshToekn = json[Credential.refreshTokenKey].string,
                                let instanceURL = json[Credential.instanceURLKey].string
                            {
                                let newCredential = Credential(
                                    accessToken: accessToken,
                                    refreshToken: refreshToekn,
                                    instanceURL: instanceURL)
                                
                                self.credentialStore.credential = newCredential
                                
                                let result = AuthResult.success(newCredential)
                                completion(result)
                            } else {
                                // TODO: - Add error code
                                let error = NSError(domain: ErrorDomain, code: 0, userInfo: nil)
                                let result = AuthResult.failure(error)
                                completion(result)
                            }
                        } else {
                            // TODO: - Add error code
                            let error = NSError(domain: ErrorDomain, code: 0, userInfo: nil)
                            let result = AuthResult.failure(error)
                            completion(result)
                        }
                    }
            }
        } else {
            // TODO: - Add error code
            let error = NSError(domain: ErrorDomain, code: 0, userInfo: nil)
            let result = AuthResult.failure(error)
            completion(result)
        }
    }
    
    public static func handleOpenURL(URL: NSURL) {
        if let redirectURL = redirectURL {
            if URL.host == redirectURL.host {
                OAuth2Swift.handleOpenURL(URL)
            }
        }
    }
    
}
