//
//  LosslessValueTests.swift
//  AwesomeDecodableTests
//
//  Created by RICHEZ Thibaut on 6/4/20.
//  Copyright © 2020 richez. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import AwesomeDecodable

fileprivate struct User: Decodable, Equatable {
    @LosslessValue.IntOrString
    private(set) var age: Int

    static var `default` = User(age: LosslessValue.Strategies.IntOrString.defaultValue)
}

final class LosslessValueTests: QuickSpec {
    override func spec() {
        self.test_givenValidJson()
        self.test_givenEntryWithAgeAsValidString()
        self.test_givenEntryWithAgeAsInvalidString()
        self.test_givenNullEntry()
        self.test_givenMissingKey()
        self.test_givenInvalidValueType()
    }
}

private extension LosslessValueTests {
    func test_givenValidJson() {
        describe("GIVEN a valid json") {
            let json = #"{ "age": 25 }"#
            let expectedResult = User(age: 25)

            context("WHEN we decode into the passed object type") {
                var sut: User?
                beforeEach {
                    expect { sut = try json.decode() }.toNot(throwError())
                }

                it("THEN it should have the right value") {
                    expect(sut).toNot(beNil())
                    expect(sut).to(equal(expectedResult))

                    expect(sut?.$age.error).to(beNil())
                }
            }
        }
    }

    func test_givenEntryWithAgeAsValidString() {
        describe("GIVEN a file with age set as a valid string") {
            let json = #"{ "age": "25" }"#
            let expectedResult = User(age: 25)

            context("WHEN we decode into the passed object type") {
                var sut: User?
                beforeEach {
                    expect { sut = try json.decode() }.toNot(throwError())
                }

                it("THEN it should have the right value") {
                    expect(sut).toNot(beNil())
                    expect(sut).to(equal(expectedResult))

                    expect(sut?.$age.error).to(beNil())
                }
            }
        }
    }

    func test_givenEntryWithAgeAsInvalidString() {
        describe("GIVEN a file with age set as an invalid string") {
            let json = #"{ "age": "I am not a number" }"#
            let expectedResult = User.default

            context("WHEN we decode into the passed object type") {
                var sut: User?
                beforeEach {
                    expect { sut = try json.decode() }.toNot(throwError())
                }

                it("THEN it should take the default value of IntOrStringDecodingStrategy") {
                    expect(sut).toNot(beNil())
                    expect(sut).to(equal(expectedResult))

                    let error = sut?.$age.error
                    expect({
                        guard case LosslessValue.DecodingError.invalidValue(let value, let type)? = error else {
                            return .failed(reason: "The error should be of type 'invalidValue'")
                        }

                        expect(value).to(equal("I am not a number"))
                        expect("\(type)").to(equal("Int"))
                        return .succeeded
                    }).to(succeed())
                }
            }
        }
    }

    func test_givenNullEntry() {
        describe("GIVEN a json with a null entry") {
            let json = #"{ "age": null }"#
            let expectedResult = User.default

            context("WHEN we decode into the passed object type") {
                var sut: User?
                beforeEach {
                    expect { sut = try json.decode() }.toNot(throwError())
                }

                it("THEN it should have the right value") {
                    expect(sut).toNot(beNil())
                    expect(sut).to(equal(expectedResult))

                    expect(sut?.$age.error).to(beNil())
                }
            }
        }
    }

    func test_givenMissingKey() {
        describe("GIVEN a json with a null entry") {
            let json = #"{ }"#
            let expectedResult = User.default

            context("WHEN we decode into the passed object type") {
                var sut: User?
                beforeEach {
                    expect { sut = try json.decode() }.toNot(throwError())
                }

                it("THEN it should have the right value") {
                    expect(sut).toNot(beNil())
                    expect(sut).to(equal(expectedResult))

                    expect(sut?.$age.error).to(beNil())
                }
            }
        }
    }

    func test_givenInvalidValueType() {
        describe("GIVEN a file with age set as an invalid value type") {
            let json = #"{ "age": [1, 2, 4] }"#
            let expectedResult = User.default

            context("WHEN we decode into the passed object type") {
                var sut: User?
                beforeEach {
                    expect { sut = try json.decode() }.toNot(throwError())
                }

                it("THEN it should take the default value of IntOrStringDecodingStrategy") {
                    expect(sut).toNot(beNil())
                    expect(sut).to(equal(expectedResult))

                    let error = sut?.$age.error
                    expect({
                        guard case LosslessValue.DecodingError.unsupportedType(let types)? = error else {
                            return .failed(reason: "The error should be of type 'unsupportedType'")
                        }

                        expect(types.map { "\($0)" }).to(equal(["String"]))
                        return .succeeded
                    }).to(succeed())
                }
            }
        }
    }
}
