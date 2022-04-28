//
//  RedisLockTests.swift
//
//
//  Created by David Monagle on 25/3/21.
//

import XCTest
import NIOCore
import NIOPosix
import RediStack
@testable import RedisLock

final class RedisLockTests: XCTestCase {
    var loop: EventLoopGroup!
    var redis: RedisConnection!
    
    override func setUp() async throws {
        loop = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        redis = try RedisConnection.make(
            configuration: try .init(hostname: "127.0.0.1"),
            boundEventLoop: loop.next()
        ).wait()
    }
    
    func testAquireLock() throws {
        let redisLock = RedisLock(key: "lock")
        try XCTAssertFalse(redisLock.isLocked(on: redis).wait())
        try XCTAssertFalse(redisLock.verifyOwnership(on: redis).wait())
        try XCTAssertTrue(redisLock.lock(on: redis).wait())
        try XCTAssertTrue(redisLock.isLocked(on: redis).wait())
        try XCTAssertTrue(redisLock.verifyOwnership(on: redis).wait())
        try XCTAssertTrue(redisLock.unlock(on: redis).wait())
        try XCTAssertFalse(redisLock.isLocked(on: redis).wait())
        try XCTAssertFalse(redisLock.verifyOwnership(on: redis).wait())
        try XCTAssertTrue(redisLock.unlock(on: redis).wait())
    }
    
    func testSimultaneousLock() throws {
        let firstLock = RedisLock(key: "simLock")
        let secondLock = RedisLock(key: "simLock")

        try XCTAssertTrue(firstLock.lock(on: redis).wait())
        try XCTAssertFalse(secondLock.lock(on: redis).wait())
        try XCTAssertTrue(firstLock.unlock(on: redis).wait())
        try XCTAssertTrue(secondLock.lock(on: redis).wait())
        try XCTAssertFalse(firstLock.verifyOwnership(on: redis).wait())
        try XCTAssertTrue(secondLock.unlock(on: redis).wait())
   }

    func testExpiringLock() throws {
        let firstLock = RedisLock(key: "expLock")
        let secondLock = RedisLock(key: "expLock")

        try XCTAssertTrue(firstLock.lock(expirySeconds: 2, on: redis).wait())
        try XCTAssertFalse(secondLock.lock(on: redis).wait())
        sleep(2)
        try XCTAssertFalse(firstLock.verifyOwnership(on: redis).wait())
        try XCTAssertTrue(secondLock.lock(on: redis).wait())
        try XCTAssertTrue(secondLock.unlock(on: redis).wait())
   }
}
