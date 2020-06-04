//
//  LosslessValue.swift
//  AwesomeDecodable
//
//  Created by RICHEZ Thibaut on 6/4/20.
//  Copyright © 2020 richez. All rights reserved.
//

import Foundation

public typealias LosslessStringDecodable = LosslessStringConvertible & Decodable

public protocol LosslessStringDecodingStrategy {
    associatedtype Value: LosslessStringDecodable

    static var defaultValue: Value { get }
    static var supportedTypes: [LosslessStringDecodable.Type] { get }
}

@propertyWrapper
public struct LosslessValue<Strategy: LosslessStringDecodingStrategy>: Decodable {
    public let wrappedValue: Strategy.Value

    public init(wrappedValue: Strategy.Value) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        do {
            self.wrappedValue = try Strategy.Value.init(from: decoder)
        } catch {
            // We use 'lazy' in order for compactMap to not execute the passed
            // closure after we successfully retrieve a valid element.
            guard let result = Strategy.supportedTypes.lazy.compactMap({ type in
                try? type.init(from: decoder)
            }).first else {
                self.wrappedValue = Strategy.defaultValue
                return
            }

            self.wrappedValue = Strategy.Value.init("\(result)") ?? Strategy.defaultValue
        }
    }
}

extension LosslessValue: Equatable where Strategy.Value: Equatable {}

extension KeyedDecodingContainer {
    /// Default implementation for decoding a LossyDecodableArray
    ///
    /// Decodes successfully if key is available. Otherwise, fallback to an empty array
    func decode<T>(_ type: LosslessValue<T>.Type,
                   forKey key: KeyedDecodingContainer<K>.Key) throws -> LosslessValue<T> {
        guard let result = try self.decodeIfPresent(type.self, forKey: key) else {
            return LosslessValue(wrappedValue: T.defaultValue)
        }

        return result
    }
}
