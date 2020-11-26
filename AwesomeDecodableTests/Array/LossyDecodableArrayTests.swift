//
//  LossyDecodableArrayTests.swift
//  AwesomeDecodableTests
//
//  Created by RICHEZ Thibaut on 5/25/20.
//  Copyright © 2020 richez. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import AwesomeDecodable

fileprivate struct Article: Decodable, Equatable {
    @LossyDecodableArray
    private(set) var keywords: [String]
}

final class LossyDecodableArrayTests: QuickSpec {
    override func spec() {
        self.test_givenValidJson()
        self.test_givenOneInvalidEntry()
        self.test_givenInvalidEntries()
        self.test_givenNullEntry()
        self.test_givenMissingKey()
        self.test_givenInvalidValueType()
    }
}

private extension LossyDecodableArrayTests {
    func test_givenValidJson() {
        describe("GIVEN a valid json and a expected result") {
            let json = #"{ "keywords": [ "sports", "news" ] }"#
            let expectedResult = Article(keywords: ["sports", "news"])

            context("WHEN we decode into the passed object type") {
                var sut: Article?
                beforeEach {
                    expect { sut = try json.decode() }.toNot(throwError())
                }

                it("THEN we should have every entries and no error") {
                    expect(sut).toNot(beNil())
                    expect(sut).to(equal(expectedResult))

                    expect(sut?.$keywords.errors).to(beEmpty())
                }
            }
        }
    }

    func test_givenOneInvalidEntry() {
        describe("GIVEN a json with one invalid entry and a expected result") {
            let json = #"{ "keywords": [ "sports", 1 ] }"#
            let expectedResult = Article(keywords: ["sports"])
            let expectedError: DecodingError = .typeMismatch(
                String.self,
                .init(codingPath: [], debugDescription: "Expected to decode String but found a number instead.")
            )

            context("WHEN we decode into the passed object type") {
                var sut: Article?
                beforeEach {
                    expect { sut = try json.decode() }.toNot(throwError())
                }

                it("THEN we should have only one entry and an error") {
                    expect(sut).toNot(beNil())
                    expect(sut).to(equal(expectedResult))

                    let errors = sut?.$keywords.errors
                    expect(errors?.count).to(equal(1))
                    expect(errors?.first as? DecodingError).to(equal(expectedError))
                }
            }
        }
    }

    func test_givenInvalidEntries() {
        describe("GIVEN a file with invalid entries") {
            let json = #"{ "keywords": [ {}, 1 ] }"#
            let firstExpectedError: DecodingError = .typeMismatch(
                String.self,
                .init(codingPath: [], debugDescription: "Expected to decode String but found a dictionary instead.")
            )
            let secondExpectedError: DecodingError = .typeMismatch(
                String.self,
                .init(codingPath: [], debugDescription: "Expected to decode String but found a number instead.")
            )

            context("WHEN we decode into the passed object type") {
                var sut: Article?
                beforeEach {
                    expect { sut = try json.decode() }.toNot(throwError())
                }

                it("THEN we should have no entries and two errors") {
                    expect(sut?.keywords).to(beEmpty())

                    let errors = sut?.$keywords.errors
                    expect(errors?.count).to(equal(2))
                    expect(errors?.first as? DecodingError).to(equal(firstExpectedError))
                    expect(errors?.last as? DecodingError).to(equal(secondExpectedError))
                }
            }
        }
    }

    func test_givenNullEntry() {
        describe("GIVEN a json with a null entry") {
            let json = #"{ "keywords": null }"#

            context("WHEN we decode into the passed object type") {
                var sut: Article?
                beforeEach {
                    expect { sut = try json.decode() }.toNot(throwError())
                }

                it("THEN we should have no entries and no error") {
                    expect(sut).toNot(beNil())
                    expect(sut?.keywords).to(beEmpty())
                    expect(sut?.$keywords.errors).to(beEmpty())
                }
            }
        }
    }

    func test_givenMissingKey() {
        describe("GIVEN a json with a missing key") {
            let json = #"{ "title": "i don't really exist" }"#

            context("WHEN we decode into the passed object type") {
                var sut: Article?
                beforeEach {
                    expect { sut = try json.decode() }.toNot(throwError())
                }

                it("THEN we should have no entries and no error") {
                    expect(sut).toNot(beNil())
                    expect(sut?.keywords).to(beEmpty())
                    expect(sut?.$keywords.errors).to(beEmpty())
                }
            }
        }
    }

    func test_givenInvalidValueType() {
        describe("GIVEN a json with a wrong value type") {
            let json = #"{ "keywords": 2 }"#
            let expectedError: DecodingError = .typeMismatch(
                Array<Any>.self,
                .init(codingPath: [], debugDescription: "Expected to decode Array<Any> but found a number instead.")
            )

            context("WHEN we decode into the passed object type") {
                var sut: Article?
                beforeEach {
                    expect { sut = try json.decode() }.toNot(throwError())
                }

                it("THEN we should have no entries and no error") {
                    expect(sut).toNot(beNil())
                    expect(sut?.keywords).to(beEmpty())

                    let errors = sut?.$keywords.errors
                    expect(errors?.count).to(equal(1))

                    let error = errors?.first as? DecodingError
                    expect(error).to(equal(expectedError))
                }
            }
        }
    }
}
