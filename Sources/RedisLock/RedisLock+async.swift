//
//  RedisLock+async.swift
//  
//
//  Created by David Monagle on 28/4/2022.
//

import NIOCore
import RediStack

#if compiler(>=5.5) && canImport(_Concurrency)

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
public extension RedisLock {
    /// Attempts to lock the key and throws if unable to
    func ensureLock(expirySeconds: Int? = nil, on redis: RedisClient) async throws {
        guard try await lock(expirySeconds: expirySeconds, on: redis).get() else {
            throw Error.failedToAquireLock(self.key)
        }
    }

    /// Attempts to lock the key and politely returns false if it is unable to
    func lock(expirySeconds: Int? = nil, on redis: RedisClient) async throws -> Bool {
        try await lock(expirySeconds: expirySeconds, on: redis).get()
    }

    /// Removes the lock, returning true if successful
    @discardableResult
    func unlock(on redis: RedisClient) async throws -> Bool {
        try await unlock(on: redis).get()
    }

    @discardableResult
    func touch(expirySeconds: Int, on redis: RedisClient) async throws -> Bool {
        try await touch(expirySeconds: expirySeconds, on: redis).get()
    }
    
    @discardableResult
    func persist(on redis: RedisClient) async throws -> Bool {
        try await persist(on: redis).get()
    }
    
    /// Check to see if the lock is owned by this instance
    func verifyOwnership(on redis: RedisClient) async throws -> Bool {
        try await verifyOwnership(on: redis).get()
    }
}

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
public extension RedisLock {
    func lock(expirySeconds: Int? = nil, on redis: RedisClient, perform: (RedisLock) async throws -> Void) async throws {
        var performError: Swift.Error? = nil
        try await self.ensureLock(expirySeconds: expirySeconds, on: redis)
        do {
            try await perform(self)
        }
        catch {
            performError = error
        }
        try await self.unlock(on: redis)
        if let performError = performError {
            throw performError
        }
    }
}

#endif
