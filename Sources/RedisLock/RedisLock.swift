//
//  RedisLock.swift
//
//
//  Created by David Monagle on 25/3/21.
//

import Foundation
import RediStack

public struct RedisLock: Codable {
    let key: RedisKey
    let id: UUID
    
    public init(key: RedisKey, id: UUID? = nil) {
        self.key = key
        self.id = id ?? UUID()
    }
}
