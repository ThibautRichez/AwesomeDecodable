//
//  DecodableDefaultTests+EmptyList.swift
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
    @DecodableDefault.EmptyList
    var names: [String]
}

fileprivate typealias DecodableDefaultEmptyMapBehavior = DecodableDefaultBehavior<Functionnality>

extension DecodableDefaultTests {
    func test_empty_list_strategy() {
        self.test_givenJsonWithValidValue()
        self.test_givenJsonWithNullValue()
        self.test_givenEmptyJson()
        self.test_givenJsonWithInvalidValue()
    }
}

private extension DecodableDefaultTests {
    func test_givenJsonWithValidValue() {
        describe("GIVEN a JSON with a list key with a valid value") {
            let json = #"{ "names": ["Onboarding"] }"#
            let expectedResult = Functionnality(names: ["Onboarding"])

            itBehavesLike(DecodableDefaultEmptyMapBehavior.self) {
                DecodableDefaultBehaviorContext(json: json, expectedResult: expectedResult)
            }
        }
    }

    func test_givenJsonWithNullValue() {
        describe("GIVEN a JSON with a null name value") {
            let json = #"{ "list": null }"#
            let expectedResult = Functionnality(names: [])

            itBehavesLike(DecodableDefaultEmptyMapBehavior.self) {
                DecodableDefaultBehaviorContext(json: json, expectedResult: expectedResult)
            }
        }
    }

    func test_givenEmptyJson() {
        describe("GIVEN a empty JSON") {
            let json = #"{ }"#
            let expectedResult = Functionnality(names: [])

            itBehavesLike(DecodableDefaultEmptyMapBehavior.self) {
                DecodableDefaultBehaviorContext(json: json, expectedResult: expectedResult)
            }
        }
    }

    func test_givenJsonWithInvalidValue() {
        describe("GIVEN a JSON with a list key with a invalid value") {
            let json = #"{ "names": ["Onboarding", 12] }"#
            let expectedResult = Functionnality(names: [])

            itBehavesLike(DecodableDefaultEmptyMapBehavior.self) {
                DecodableDefaultBehaviorContext(json: json, expectedResult: expectedResult)
            }
        }
    }
}
