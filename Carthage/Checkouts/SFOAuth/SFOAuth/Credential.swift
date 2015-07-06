//
//  Credential.swift
//  SFOAuth
//
//  Created by MiyakeAkira on 2015/07/06.
//  Copyright (c) 2015年 Miyake Akira. All rights reserved.
//

public struct Credential {
    
    // MARK: - Static let
    
    public static let accessTokenKey = "access_token"
    public static let refreshTokenKey = "refresh_token"
    public static let instanceURLKey = "instance_url"
    
    
    // MARK: - let
    
    public let accessToken: String
    public let refreshToken: String
    public let instanceURL: String
    
    
    // MARK: - Initialize
    
    init(accessToken: String, refreshToken: String, instanceURL: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.instanceURL = instanceURL
    }
    
    init(dict: [String: String]) {
        self.accessToken = dict[Credential.accessTokenKey]!
        self.refreshToken = dict[Credential.refreshTokenKey]!
        self.instanceURL = dict[Credential.instanceURLKey]!
    }
    
    
    // MARK: - Method
    
    func toDictionary() -> [String: String] {
        return [
            Credential.accessTokenKey: accessToken,
            Credential.refreshTokenKey: refreshToken,
            Credential.instanceURLKey: instanceURL
        ]
    }
    
}
