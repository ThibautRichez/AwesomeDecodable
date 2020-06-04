//
//  LosslessStringDecodingStrategy.swift
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
