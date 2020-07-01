//
//  LosslessValue.swift
//  AwesomeDecodable
//
//  Created by RICHEZ Thibaut on 6/4/20.
//  Copyright © 2020 richez. All rights reserved.
//

import Foundation

public enum LosslessValue {
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
    public struct Wrapper<Strategy: LosslessStringDecodingStrategy>: Decodable {
        public typealias Value = Strategy.Value

        public let wrappedValue: Value
        private(set) public var error: DecodingError?

        public var projectedValue: Wrapper { self }

        public init(wrappedValue: Value) {
            self.wrappedValue = wrappedValue
        }

        public init(from decoder: Decoder) throws {
            do {
                self.wrappedValue = try Value.init(from: decoder)
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

                guard let result = Value.init("\(value)") else {
                    self.wrappedValue = Strategy.defaultValue
                    self.error = .invalidValue("\(value)", type: Value.self)
                    return
                }

                self.wrappedValue = result
            }
        }
    }
}

public extension LosslessValue {
    enum DecodingError {
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
}

public extension LosslessValue {
    enum Strategies {
        /// A Strategy that defines that the expected type is `Int` but should try
        /// to decode the data as a `String` also.
        /// If the decoding process fails, the property value will be `0`
        public enum IntOrString: LosslessStringDecodingStrategy {
            public static var defaultValue: Int { 0 }
            public static var supportedTypes: [LosslessStringDecodable.Type] { [String.self] }
        }

        public enum StringOrInt: LosslessStringDecodingStrategy {
            public static var defaultValue: String { "" }
            public static var supportedTypes: [LosslessStringDecodable.Type] { [Int.self] }
        }

        public enum TrueOrString: LosslessStringDecodingStrategy {
            public static var defaultValue: Bool { true }
            public static var supportedTypes: [LosslessStringDecodable.Type] { [String.self] }
        }

        public enum FalseOrString: LosslessStringDecodingStrategy {
            public static var defaultValue: Bool { false }
            public static var supportedTypes: [LosslessStringDecodable.Type] { [String.self] }
        }
    }
}

public extension LosslessValue {
    typealias IntOrString = Wrapper<Strategies.IntOrString>

    typealias StringOrInt = Wrapper<Strategies.StringOrInt>

    typealias TrueOrString = Wrapper<Strategies.TrueOrString>

    typealias FalseOrString = Wrapper<Strategies.FalseOrString>
}

extension LosslessValue.Wrapper: Equatable where Value: Equatable {
    public static func == (lhs: LosslessValue.Wrapper<Strategy>,
                           rhs: LosslessValue.Wrapper<Strategy>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension LosslessValue.Wrapper: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.wrappedValue)
    }
}

extension LosslessValue.Wrapper: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        try self.wrappedValue.encode(to: encoder)
    }
}

extension KeyedDecodingContainer {
    /// Default implementation for decoding a LossyDecodableArray
    ///
    /// Decodes successfully if key is available. Otherwise, fallback to the default value.
    func decode<T>(_ type: LosslessValue.Wrapper<T>.Type,
                   forKey key: KeyedDecodingContainer<K>.Key) throws -> LosslessValue.Wrapper<T> {
        guard let result = try self.decodeIfPresent(type.self, forKey: key) else {
            return LosslessValue.Wrapper(wrappedValue: T.defaultValue)
        }

        return result
    }
}
