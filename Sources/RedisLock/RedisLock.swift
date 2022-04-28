//
//  RedisLock.swift
//
//
//  Created by David Monagle on 25/3/21.
//

import Foundation
import RediStack

public struct RedisLock {
    let key: RedisKey
    let id: UUID
    
    public init(key: String) {
        self.key = .init(key)
        self.id = UUID()
    }

    public init(key: RedisKey) {
        self.key = key
        self.id = UUID()
    }
}
