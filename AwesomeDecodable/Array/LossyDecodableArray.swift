//
//  LossyDecodableArray.swift
//  AwesomeDecodable
//
//  Created by RICHEZ Thibaut on 5/25/20.
//  Copyright © 2020 richez. All rights reserved.
//

import Foundation

/// Empty object conforming to `Decodable` used
/// in order to move the `UnkeyedDecodingContainer`
/// cursor if we fail to decode to an actual type.
fileprivate struct DecodableDummy: Decodable {}

/// A `propertyWrapper` that allows a lossy array decoding.
///`
///
/// `@LossyDecodableArray` decodes any `Decodable` array by skipping
/// invalid values.
/// You can inspect if one or multiple errors had happenend by
/// accessing the `$variable.errors` array that will contains
/// `DecodingError`s that occured for each skipped elements.
///
/// This is useful for array that contain non-optional types and prevents one
/// or multiple badly formated JSON object to result to a global `DecodingError`.
/// This will also set the value to an empty array if the key is not present or
/// if its associated value is 'null'
@propertyWrapper
public struct LossyDecodableArray<Element: Decodable>: Decodable {
    public let wrappedValue: [Element]
    private(set) public var errors: [Error] = []

    public var projectedValue: LossyDecodableArray { self }

    public init(wrappedValue: [Element]) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements = [Element]()
        while !container.isAtEnd {
            do {
                let element = try container.decode(Element.self)
                elements.append(element)
            } catch {
                self.errors.append(error)

                // if that fails, we still need to move our decoding cursor past that element
                // to avoid infinite loop.
                _ = try? container.decode(DecodableDummy.self)
            }
        }

        self.wrappedValue = elements
    }
}

extension LossyDecodableArray: Equatable where Element: Equatable {
    public static func == (lhs: LossyDecodableArray<Element>,
                           rhs: LossyDecodableArray<Element>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension KeyedDecodingContainer {
    /// Default implementation for decoding a LossyDecodableArray
    ///
    /// Decodes successfully if key is available. Otherwise, fallback to an empty array
    func decode<T>(_ type: LossyDecodableArray<T>.Type,
                   forKey key: KeyedDecodingContainer<K>.Key) throws -> LossyDecodableArray<T> {
        guard let result = try self.decodeIfPresent(type.self, forKey: key) else {
            return LossyDecodableArray(wrappedValue: [])
        }

        return result
    }
}
