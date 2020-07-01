//
//  DecodableDefaultTests+EmptyString.swift
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
    @DecodableDefault.EmptyString
    var name: String
}

fileprivate typealias DecodableDefaultEmptyStringBehavior = DecodableDefaultBehavior<Functionnality>

extension DecodableDefaultTests {
    func test_empty_string_strategy() {
        self.test_givenJsonWithValidValue()
        self.test_givenJsonWithNullValue()
        self.test_givenEmptyJson()
        self.test_givenJsonWithInvalidValue()
    }
}

private extension DecodableDefaultTests {
    func test_givenJsonWithValidValue() {
        describe("GIVEN a JSON with a name key with a valid value") {
            let json = #"{ "name": "Onboarding" }"#
            let expectedResult = Functionnality(name: "Onboarding")

            itBehavesLike(DecodableDefaultEmptyStringBehavior.self) {
                DecodableDefaultBehaviorContext(json: json, expectedResult: expectedResult)
            }
        }
    }


    func test_givenJsonWithNullValue() {
        describe("GIVEN a JSON with a null name value") {
            let json = #"{ "name": null }"#
            let expectedResult = Functionnality(name: "")

            itBehavesLike(DecodableDefaultEmptyStringBehavior.self) {
                DecodableDefaultBehaviorContext(json: json, expectedResult: expectedResult)
            }
        }
    }

    func test_givenEmptyJson() {
        describe("GIVEN a empty JSON") {
            let json = #"{ }"#
            let expectedResult = Functionnality(name: "")

            itBehavesLike(DecodableDefaultEmptyStringBehavior.self) {
                DecodableDefaultBehaviorContext(json: json, expectedResult: expectedResult)
            }
        }
    }

    func test_givenJsonWithInvalidValue() {
        describe("GIVEN a JSON with a name key with an invalid value") {
            let json = #"{ "name": true }"#
            let expectedResult = Functionnality(name: "")

            itBehavesLike(DecodableDefaultEmptyStringBehavior.self) {
                DecodableDefaultBehaviorContext(json: json, expectedResult: expectedResult)
            }
        }
    }
}


