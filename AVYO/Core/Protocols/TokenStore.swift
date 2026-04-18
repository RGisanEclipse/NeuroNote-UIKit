//
//  TokenStore.swift
//  AVYO
//
//  Created by Eclipse on 09/09/25.
//

protocol TokenStore {
    func getRefreshToken() -> String?
}
