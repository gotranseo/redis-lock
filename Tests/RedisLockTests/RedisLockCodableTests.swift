//
//  RedisLockCodableTests.swift
//  
//
//  Created by David Monagle on 28/4/2022.
//

import XCTest
import NIOCore
import NIOPosix
import RediStack
@testable import RedisLock

final class RedisLockCodableTests: XCTestCase {
    var loop: EventLoopGroup!
    var redis: RedisConnection!
    
    override func setUp() async throws {
        loop = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        redis = try RedisConnection.make(
            configuration: try .init(hostname: "127.0.0.1"),
            boundEventLoop: loop.next()
        ).wait()
    }
    
    func testCodableLock() async throws {
        let redisLock = RedisLock(key: "lock")
        let _ = try await redisLock.lock(on: redis)
        let originalLockIsOwner = try await redisLock.verifyOwnership(on: redis)
        XCTAssertTrue(originalLockIsOwner)
        
        let encoded = try JSONEncoder().encode(redisLock)
        
        let decoded = try JSONDecoder().decode(RedisLock.self, from: encoded)
        let decodedLockIsOwner = try await decoded.verifyOwnership(on: redis)
        XCTAssertTrue(decodedLockIsOwner)
    }
}
