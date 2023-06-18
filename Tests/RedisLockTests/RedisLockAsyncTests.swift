//
//  RedisLockAsyncTests.swift
//  
//
//  Created by David Monagle on 28/4/2022.
//

import XCTest
import NIOCore
import NIOPosix
import RediStack
@testable import RedisLock

final class RedisLockAsyncTests: XCTestCase {
    var loop: EventLoopGroup!
    var redis: RedisConnection!
    
    override func setUp() async throws {
        loop = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        redis = try RedisConnection.make(
            configuration: try .init(hostname: "127.0.0.1"),
            boundEventLoop: loop.next()
        ).wait()
    }
    
    func testScopedLock() async throws {
        let scopedLock = RedisLock(key: "scopedLock")
        try await scopedLock.lock(on: redis) { lock in
            let isOwned = try await lock.verifyOwnership(on: redis)
            XCTAssertTrue(isOwned)
        }
        let isOwned = try await scopedLock.verifyOwnership(on: redis)
        XCTAssertFalse(isOwned)
    }
}
