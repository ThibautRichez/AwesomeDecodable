//
//  DecodableDefaultTests+False.swift
//  AwesomeDecodableTests
//
//  Created by RICHEZ Thibaut on 6/16/20.
//  Copyright © 2020 richez. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import AwesomeDecodable

fileprivate struct Functionnality: Decodable, Equatable {
    @DecodableDefault.False
    var enable: Bool
}

fileprivate typealias DecodableDefaultFalseBehavior = DecodableDefaultBehavior<Functionnality>

extension DecodableDefaultTests {
    func test_false_strategy() {
        self.test_givenJsonWithTrueValue()
        self.test_givenJsonWithFalseValue()
        self.test_givenJsonWithNullValue()
        self.test_givenEmptyJson()
        self.test_givenJsonWithInvalidValue()
    }
}

private extension DecodableDefaultTests {
    func test_givenJsonWithTrueValue() {
        describe("GIVEN a JSON with an enable key set to true") {
            let json = #"{ "enable": true }"#
            let expectedResult = Functionnality(enable: true)

            itBehavesLike(DecodableDefaultFalseBehavior.self) {
                DecodableDefaultBehaviorContext(json: json, expectedResult: expectedResult)
            }
        }
    }

    func test_givenJsonWithFalseValue() {
        describe("GIVEN a JSON with an enable key set to false") {
            let json = #"{ "enable": false }"#
            let expectedResult = Functionnality(enable: false)

            itBehavesLike(DecodableDefaultFalseBehavior.self) {
                DecodableDefaultBehaviorContext(json: json, expectedResult: expectedResult)
            }
        }
    }

    func test_givenJsonWithNullValue() {
        describe("GIVEN a JSON with a null enable value") {
            let json = #"{ "enable": null }"#
            let expectedResult = Functionnality(enable: false)

            itBehavesLike(DecodableDefaultFalseBehavior.self) {
                DecodableDefaultBehaviorContext(json: json, expectedResult: expectedResult)
            }
        }
    }

    func test_givenEmptyJson() {
        describe("GIVEN a empty JSON") {
            let json = #"{ }"#
            let expectedResult = Functionnality(enable: false)

            itBehavesLike(DecodableDefaultFalseBehavior.self) {
                DecodableDefaultBehaviorContext(json: json, expectedResult: expectedResult)
            }
        }
    }

    func test_givenJsonWithInvalidValue() {
        describe("GIVEN a JSON with an enable key with an invalid value") {
            let json = #"{ "enable": "I think not" }"#
            let expectedResult = Functionnality(enable: false)

            itBehavesLike(DecodableDefaultFalseBehavior.self) {
                DecodableDefaultBehaviorContext(json: json, expectedResult: expectedResult)
            }
        }
    }
}
