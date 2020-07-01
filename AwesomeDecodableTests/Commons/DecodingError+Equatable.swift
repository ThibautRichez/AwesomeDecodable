//
//  DecodingError+Equatable.swift
//  AwesomeDecodableTests
//
//  Created by RICHEZ Thibaut on 7/1/20.
//  Copyright © 2020 richez. All rights reserved.
//

import Foundation

extension DecodingError: Equatable {
    public static func == (lhs: DecodingError, rhs: DecodingError) -> Bool {
        switch (lhs, rhs) {
        case (
            .typeMismatch(let lhsType, let lhsContext),
            .typeMismatch(let rhsType, let rhsContext)):
            return lhsType == rhsType && lhsContext == rhsContext

        case (
            .valueNotFound(let lhsType, let lhsContext),
            .valueNotFound(let rhsType, let rhsContext)):
            return lhsType == rhsType && lhsContext == rhsContext

        case (
            .keyNotFound(let lhsKey, let lhsContext),
            .keyNotFound(let rhsKey, let rhsContext)):
            return lhsKey.debugDescription == rhsKey.debugDescription && lhsContext == rhsContext

        case (
            .dataCorrupted(let lhsContext),
            .dataCorrupted(let rhsContext)):
            return lhsContext == rhsContext

        default:
            return false
        }
    }
}

extension DecodingError.Context: Equatable {
    public static func == (lhs: DecodingError.Context, rhs: DecodingError.Context) -> Bool {
        lhs.debugDescription == rhs.debugDescription
    }
}
