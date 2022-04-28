//
//  RedisLock+NIO.swift
//  
//
//  Created by David Monagle on 28/4/2022.
//

import NIOCore
import RediStack

public extension RedisLock {
    func lock(expirySeconds: Int? = nil, on redis: RedisClient) -> EventLoopFuture<Bool> {
        let expiration: RedisSetCommandExpiration?
        
        if let expirySeconds = expirySeconds {
            expiration = .seconds(expirySeconds)
        }
        else {
            expiration = nil
        }
        
        return redis.set(key, to: id.uuidString, onCondition: .keyDoesNotExist, expiration: expiration)
            .map { result in
                result == .ok
            }
    }
    
    func unlock(on redis: RedisClient) -> EventLoopFuture<Bool> {
        redis.unlock(self.key, using: self.id)
    }
    
    func touch(expirySeconds: Int, on redis: RedisClient) -> EventLoopFuture<Bool> {
        verifyOwnership(on: redis).flatMap { owner in
            guard owner else { return redis.eventLoop.makeSucceededFuture(false) }
            return redis.expire(self.key, after: .seconds(Int64(expirySeconds)))
        }
    }
    
    func persist(on redis: RedisClient) -> EventLoopFuture<Bool> {
        verifyOwnership(on: redis).flatMap { owner in
            guard owner else { return redis.eventLoop.makeSucceededFuture(false) }
            return redis.persist(self.key)
        }
    }
    
    /// Check to see if the lock is owned by this instance
    func verifyOwnership(on redis: RedisClient) -> EventLoopFuture<Bool> {
        redis.get(key)
            .map { result in
                guard let uuidString = result.string, uuidString == self.id.uuidString else { return false }
                return true
            }
    }
}
