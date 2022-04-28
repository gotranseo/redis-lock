//
//  Error.swift
//  
//
//  Created by David Monagle on 28/4/2022.
//

import RediStack
import Foundation

extension RedisLock {
    public enum Error: Swift.Error, LocalizedError {
        case failedToAquireLock(RedisKey)
        case notTheOwner(RedisKey)
        
        public var errorDescription: String? {
            switch self {
            case .failedToAquireLock(let key): return "Failed to get a RedisLock for key: '\(key)'"
            case .notTheOwner(let key): return "Not the owner of RedisLock key: '\(key)'"
            }
        }
    }
}
