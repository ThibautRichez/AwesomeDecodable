//
//  LosslessValue.swift
//  AwesomeDecodable
//
//  Created by RICHEZ Thibaut on 6/4/20.
//  Copyright © 2020 richez. All rights reserved.
//

import Foundation

public enum LosslessValueDecodingError: Error {
    /// An indication that a value could not be decoded because
    /// it did not match any of the supported types.
    ///
    /// As associated values, this case contains the supported types
    case unsupportedType([LosslessStringDecodable.Type])

    /// An indication that the decoded value could not be used to instanciate
    /// the requested type from its string representation.
    ///
    /// As associated values, this case contains the decoded value and
    /// the requested type.
    case invalidValue(_ value: String, type: LosslessStringDecodable.Type)

}

/// A `propertyWrapper` that allows the decoding of dynamic
/// `LosslessStringDecodable` types.
///`
///
/// `@LosslessValue` decodes any `LosslessStringDecodable` defined
/// by the passed `LosslessStringDecodingStrategy`.
/// It will first try to decode the value with the passed type, if it fails
/// it will then try with every types from `supportedTypes`.
/// If none of them give the expected result, the `defaultValue` will be
/// applied.
///
/// You can inspect if an error had happenend by accessing
/// the `$variable.error` that will contains `LosslessValueDecodingError`
/// explaining why the default value was applied.
///
/// This is useful when data is returned with unpredictable types form a provider.
/// For instance, if an API sends either an `Int` or `String` for a given property.
@propertyWrapper
public struct LosslessValue<Strategy: LosslessStringDecodingStrategy>: Decodable {
    public let wrappedValue: Strategy.Value
    private(set) public var error: LosslessValueDecodingError?

    public var projectedValue: LosslessValue { self }

    public init(wrappedValue: Strategy.Value) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        do {
            self.wrappedValue = try Strategy.Value.init(from: decoder)
        } catch {
            // We use 'lazy' in order for compactMap to not execute its closure
            // after we successfully retrieve a valid element.
            guard let value = Strategy.supportedTypes.lazy.compactMap({ type in
                try? type.init(from: decoder)
            }).first else {
                self.wrappedValue = Strategy.defaultValue
                self.error = .unsupportedType(Strategy.supportedTypes)
                return
            }

            guard let result = Strategy.Value.init("\(value)") else {
                self.wrappedValue = Strategy.defaultValue
                self.error = .invalidValue("\(value)", type: Strategy.Value.self)
                return
            }

            self.wrappedValue = result
        }
    }
}

extension LosslessValue: Equatable where Strategy.Value: Equatable {
    public static func == (lhs: LosslessValue<Strategy>,
                           rhs: LosslessValue<Strategy>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension KeyedDecodingContainer {
    /// Default implementation for decoding a LossyDecodableArray
    ///
    /// Decodes successfully if key is available. Otherwise, fallback to the default value.
    func decode<T>(_ type: LosslessValue<T>.Type,
                   forKey key: KeyedDecodingContainer<K>.Key) throws -> LosslessValue<T> {
        guard let result = try self.decodeIfPresent(type.self, forKey: key) else {
            return LosslessValue(wrappedValue: T.defaultValue)
        }

        return result
    }
}
