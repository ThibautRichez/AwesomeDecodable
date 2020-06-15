//
//  LosslessStringDecodingStrategy.swift
//  AwesomeDecodable
//
//  Created by RICHEZ Thibaut on 6/4/20.
//  Copyright © 2020 richez. All rights reserved.
//

import Foundation

public typealias LosslessStringDecodable = LosslessStringConvertible & Decodable

/// Defines the strategy to be used by `LosslessValue` during the decoding
/// process.
public protocol LosslessStringDecodingStrategy {
    /// Represents the expected variable type.
    associatedtype Value: LosslessStringDecodable

    /// Defines the default value that will be used if the decoding process fails.
    static var defaultValue: Value { get }

    /// Defines the `LosslessStringDecodable` types that must be handle during the
    /// decoding process.
    static var supportedTypes: [LosslessStringDecodable.Type] { get }
}
