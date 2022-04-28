# RedisLock

This is an implementation of a single instance Redis Lock as described in  [Distributed Locks with Redis](https://redis.io/docs/reference/patterns/distributed-locks/).

* Uses a [RediStack](https://github.com/Mordil/RediStack) client which sits on SwiftNIO
* Supports Swift async calls

## Example

These examples are simple and all use async/await. EventLoopFuture versions exist of all the APIs. Have a look at
the tests for more insight.

```swift
    let firstLock = RedisLock(key: "simLock")
    let secondLock = RedisLock(key: "simLock")

    try await firstLock.lock(expirySeconds: 20, on: redis) // Succeeds
    try await firstLock.isLocked(on: redis) // true
    try await secondLock.ensureLock(on: redis) // Throws because it uses the same key as the active lock
    try await secondLock.isLocked(on: redis) // true, even though it's not the owner
    
    try await firstLock.unlock(on: redis)
    try await secondLock.ensureLock(on: redis) // Works now because the first lock succeeded
    try await firstLock.verifyOwnership(on: redis) // false
    try await secondLock.verifyOwnership(on: redis) // true
```

## Installing

To install **RedisLock**, just add it to **Package.swift** in the top level dependencies section.

```swift
dependencies: [
    .package(url: "https://github.com/monagle-au/RedisLock.git", from: "1.0.0")
]
```

And add it to your target dependencies like this:

```swift
    .product(name: "RedisLock", package: "redis-lock")
```
