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
        redis = try await RedisConnection.make(
            configuration: try .init(hostname: ProcessInfo.processInfo.environment["REDIS_HOSTNAME"] ?? "localhost", port: ProcessInfo.processInfo.environment["REDIS_PORT"].flatMap(Int.init(_:)) ?? 6379),
            boundEventLoop: loop.next()
        ).get()
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
