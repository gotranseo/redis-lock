//
//  RedisClient+unlock-persist.swift
//  
//
//  Created by David Monagle on 28/4/2022.
//

import Foundation
import RediStack
import NIOCore

let UnlockLuaScript = RESPValue(from: """
    if redis.call("EXISTS",KEYS[1]) == 0 then
        return 1
    elseif redis.call("GET",KEYS[1]) == ARGV[1] then
        return redis.call("del",KEYS[1])
    else
        return 0
    end
""")

extension RedisClient {
    /// Attempts to unlock the `key` if it's owned by the `uuid`
    /// - Parameters:
    ///   - key: The key to the lock
    ///   - id: The uuid that should own the lock for it to be successfully unlocked
    /// - Returns: `true` if the key is unlocked after the operation, otherwise `false`
    ///
    /// If the key does not exist, it is deemed unlocked. This is so that a legitimate request
    /// to unlock an expired key doesn't cause an unexpected failure.
    func unlock(_ key: RedisKey, using id: UUID) -> EventLoopFuture<Bool> {
        self.send(command: "EVAL", with: [UnlockLuaScript, RESPValue(from: 1), key.convertedToRESPValue(), RESPValue(from: id.uuidString)]).map {
            guard let value = $0.int, value != 0 else { return false }
            return true
        }
    }
    
    func persist(_ key: RedisKey) -> EventLoopFuture<Bool> {
        self.send(command: "PERSIST", with: [key.convertedToRESPValue()])
            .map {
                guard let value = $0.int, value != 0 else { return false }
                return true
            }
    }
}
