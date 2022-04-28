//
//  Error.swift
//  
//
//  Created by David Monagle on 28/4/2022.
//

import RediStack

extension RedisLock {
    public enum Error: Swift.Error {
        case failedToAquireLock(RedisKey)
    }
}
