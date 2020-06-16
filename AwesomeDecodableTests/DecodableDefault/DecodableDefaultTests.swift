//
//  DecodableDefaultTests.swift
//  AwesomeDecodableTests
//
//  Created by RICHEZ Thibaut on 6/16/20.
//  Copyright © 2020 richez. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import AwesomeDecodable

final class DecodableDefaultTests: QuickSpec {
    override func spec() {
        self.test_true_strategy()
        self.test_false_strategy()
        self.test_empty_string_strategy()
        self.test_empty_list_strategy()
        self.test_empty_map_strategy()
        self.test_zero_strategy()
    }
}

struct DecodableDefaultBehaviorContext<T: Decodable & Equatable> {
    let json: String
    let expectedResult: T
}

final class DecodableDefaultBehavior<T: Decodable & Equatable>: Behavior<DecodableDefaultBehaviorContext<T>> {
    override class func spec(_ aContext: @escaping () -> DecodableDefaultBehaviorContext<T>) {
        describe("GIVEN a json and a expected result") {
            var json: String!
            var expectedResult: T!
            beforeEach {
                json = aContext().json
                expectedResult = aContext().expectedResult
            }

            context("WHEN we decode into the passed object type") {
                var sut: T!
                beforeEach {
                    expect { sut = try json.decode() }.toNot(throwError())
                }

                it("THEN it should have the expected value") {
                    expect(sut).toNot(beNil())
                    expect(sut).to(equal(expectedResult))
                }
            }
        }
    }
}
