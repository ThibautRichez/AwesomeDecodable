//
//  DecodableDefault.swift
//  AwesomeDecodable
//
//  Created by RICHEZ Thibaut on 6/15/20.
//  Copyright © 2020 richez. All rights reserved.
//

import Foundation

public protocol DecodableDefaultStrategy {
    associatedtype Value: Decodable
    static var defaultValue: Value { get }
}

public enum DecodableDefault {
    @propertyWrapper
    public struct Wrapper<Strategy: DecodableDefaultStrategy>: Decodable {
        public typealias Value = Strategy.Value

        public let wrappedValue: Value

        public init(wrappedValue: Value) {
            self.wrappedValue = wrappedValue
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.wrappedValue = try container.decode(Value.self)
        }
    }
}

public extension DecodableDefault {
    typealias DecodableList = Decodable & ExpressibleByArrayLiteral
    typealias DecodableMap = Decodable & ExpressibleByDictionaryLiteral
    typealias DecodableNumeric = Decodable & Numeric

    enum Strategies {
        public enum True: DecodableDefaultStrategy {
            public static var defaultValue: Bool { true }
        }

        public enum False: DecodableDefaultStrategy {
            public static var defaultValue: Bool { false }
        }

        public enum EmptyString: DecodableDefaultStrategy {
            public static var defaultValue: String { "" }
        }

        public enum EmptyList<T: DecodableList>: DecodableDefaultStrategy {
            public static var defaultValue: T { [] }
        }

        public enum EmptyMap<T: DecodableMap>: DecodableDefaultStrategy {
            public static var defaultValue: T { [:] }
        }

        public enum Zero<T: DecodableNumeric>: DecodableDefaultStrategy {
            public static var defaultValue: T { 0 }
        }
    }
}

public extension DecodableDefault {
    // MARK: - Bool

    typealias True = Wrapper<Strategies.True>
    typealias False = Wrapper<Strategies.False>

    // MARK: - String

    typealias EmptyString = Wrapper<Strategies.EmptyString>

    // MARK: - List

    typealias EmptyList<T: DecodableList> = Wrapper<Strategies.EmptyList<T>>

    // MARK: - Map

    typealias EmptyMap<T: DecodableMap> = Wrapper<Strategies.EmptyMap<T>>

    // MARK: - Number

    typealias Zero<T: DecodableNumeric> = Wrapper<Strategies.Zero<T>>
}

extension DecodableDefault.Wrapper: Equatable where Value: Equatable {}
extension DecodableDefault.Wrapper: Hashable where Value: Hashable {}

extension DecodableDefault.Wrapper: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.wrappedValue)
    }
}


extension KeyedDecodingContainer {
    /// Default implementation for decoding a `DecodableDefault.Wrapper`
    ///
    /// Decodes successfully if the key exists and value has the expected type.
    /// Otherwise, fallback to the default value.
    func decode<T>(_ type: DecodableDefault.Wrapper<T>.Type,
                   forKey key: KeyedDecodingContainer<K>.Key) throws -> DecodableDefault.Wrapper<T> {
        guard let result = try? self.decodeIfPresent(type.self, forKey: key) else {
            return DecodableDefault.Wrapper(wrappedValue: T.defaultValue)
        }

        return result
    }
}
