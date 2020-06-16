//
//  DecodableDefaultTests+Zero.swift
//  AwesomeDecodableTests
//
//  Created by RICHEZ Thibaut on 6/17/20.
//  Copyright © 2020 richez. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import AwesomeDecodable

fileprivate struct Article: Decodable, Equatable {
    @DecodableDefault.Zero
    var comments: Int
}

fileprivate typealias DecodableDefaultEmptyMapBehavior = DecodableDefaultBehavior<Article>

extension DecodableDefaultTests {
    func test_zero_strategy() {
        self.test_givenJsonWithValidValue()
        self.test_givenJsonWithNullValue()
        self.test_givenEmptyJson()
        self.test_givenJsonWithInvalidValue()
    }
}

private extension DecodableDefaultTests {
    func test_givenJsonWithValidValue() {
        describe("GIVEN a JSON with a list key with a valid value") {
            let json = #"{ "comments": 3 }"#
            let expectedResult = Article(comments: 3)

            itBehavesLike(DecodableDefaultEmptyMapBehavior.self) {
                DecodableDefaultBehaviorContext(json: json, expectedResult: expectedResult)
            }
        }
    }

    func test_givenJsonWithNullValue() {
        describe("GIVEN a JSON with a null name value") {
            let json = #"{ "comments": null }"#
            let expectedResult = Article(comments: 0)

            itBehavesLike(DecodableDefaultEmptyMapBehavior.self) {
                DecodableDefaultBehaviorContext(json: json, expectedResult: expectedResult)
            }
        }
    }

    func test_givenEmptyJson() {
        describe("GIVEN a empty JSON") {
            let json = #"{ }"#
            let expectedResult = Article(comments: 0)

            itBehavesLike(DecodableDefaultEmptyMapBehavior.self) {
                DecodableDefaultBehaviorContext(json: json, expectedResult: expectedResult)
            }
        }
    }

    func test_givenJsonWithInvalidValue() {
        describe("GIVEN a JSON with a list key with a invalid value") {
            let json = #"{ "comments": "Je ne suis pas d'accord" }"#
            let expectedResult = Article(comments: 0)

            itBehavesLike(DecodableDefaultEmptyMapBehavior.self) {
                DecodableDefaultBehaviorContext(json: json, expectedResult: expectedResult)
            }
        }
    }
}
