//
//  RedisLock+NIO.swift
//  
//
//  Created by David Monagle on 28/4/2022.
//

import NIOCore
import RediStack

public extension RedisLock {
    /// Attempts to lock the key and politely returns false if it is unable to
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
    
    /// Checks if a lock is active for the key
    func isLocked(on redis: RedisClient) -> EventLoopFuture<Bool> {
        redis.exists(key).map { result in
            return result != 0
        }
    }
    
    /// Removes the lock, returning true if successful
    func unlock(on redis: RedisClient) -> EventLoopFuture<Bool> {
        redis.unlock(self.key, using: self.id)
    }
    
    /// Updates an existing lock with a new expiry
    func touch(expirySeconds: Int, on redis: RedisClient) -> EventLoopFuture<Bool> {
        verifyOwnership(on: redis).flatMap { owner in
            guard owner else { return redis.eventLoop.makeSucceededFuture(false) }
            return redis.expire(self.key, after: .seconds(Int64(expirySeconds)))
        }
    }
    
    /// Removes any expiry on an active lock
    func persist(on redis: RedisClient) -> EventLoopFuture<Bool> {
        verifyOwnership(on: redis).flatMap { owner in
            guard owner else { return redis.eventLoop.makeSucceededFuture(false) }
            return redis.persist(self.key)
        }
    }
    
    /// Check to see if the lock is owned by this instance, this also returns false if there is no active lock
    func verifyOwnership(on redis: RedisClient) -> EventLoopFuture<Bool> {
        redis.get(key)
            .map { result in
                guard let uuidString = result.string, uuidString == self.id.uuidString else { return false }
                return true
            }
    }
}
