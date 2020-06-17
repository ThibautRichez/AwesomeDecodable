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

fileprivate struct Article: Decodable, Equatable {
    @LossyDecodableArray
    private(set) var keywords: [String]
}

class LossyDecodableArrayTests: QuickSpec {
    override func spec() {
        self.test_givenValidJson()
        self.test_givenOneInvalidEntry()
        self.test_givenInvalidEntries()
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

    // TODOT: Refacto test_givenNullEntry, test_givenMissingKey()
    // TODOT: Add test_givenInvalidValue (type)
}

//class LossyDecodableArrayTests: QuickSpec {
//    private var fileReader: FileReader!
//    private var decoder: JSONDecoder!
//
//    override func spec() {
//        describe("GIVEN a file reader and a decoder") {
//            beforeEach {
//                self.fileReader = FileReader()
//                self.decoder = JSONDecoder()
//            }
//
//            afterEach {
//                self.fileReader = nil
//                self.decoder = nil
//            }
//
//            self.test_givenValidEntries()
//            self.test_givenOneInvalidEntry()
//            self.test_givenInvalidEntries()
//            self.test_givenNullEntry()
//            self.test_givenMissingKey()
//        }
//    }
//}
//
//private extension LossyDecodableArrayTests {
//    func test_givenValidEntries() {
//        describe("GIVEN a file with valid article entries") {
//            let filename = "valid-articles"
//            var sut: ArticleList?
//
//            let firstExpectedArticle = Article(identifier: 122, title: "I am the first article")
//            let lastExepectedArticle = Article(identifier: 54, title: "I am sadly the last one")
//
//            context("WHEN we decode the associated data") {
//                beforeEach {
//                    do {
//                        let data = try self.fileReader.get(filename: filename)
//                        sut = try self.decoder.decode(ArticleList.self, from: data)
//                    } catch {
//                        fail("An error occured: \(error)")
//                    }
//                }
//
//                it("THEN we should have every entries and no error") {
//                    expect(sut).toNot(beNil())
//                    expect(sut?.articles.count).to(equal(2))
//                    expect(sut?.articles.first).to(equal(firstExpectedArticle))
//                    expect(sut?.articles.last).to(equal(lastExepectedArticle))
//
//                    expect(sut?.$articles.errors).to(beEmpty())
//                }
//            }
//        }
//    }
//
//    func test_givenOneInvalidEntry() {
//        describe("GIVEN a file with one invalid article") {
//            let filename = "one-invalid-article"
//            var sut: ArticleList?
//
//            let expectedArticle = Article(identifier: 1, title: "I'm the only valid one")
//
//            context("WHEN we decode the associated data") {
//                beforeEach {
//                    do {
//                        let data = try self.fileReader.get(filename: filename)
//                        sut = try self.decoder.decode(ArticleList.self, from: data)
//                    } catch {
//                        fail("An error occured: \(error)")
//                    }
//                }
//
//                it("THEN we should have only one entry and an error") {
//                    expect(sut).toNot(beNil())
//                    expect(sut?.articles.count).to(equal(1))
//                    expect(sut?.articles.first).to(equal(expectedArticle))
//
//                    let errors = sut?.$articles.errors
//                    expect(errors?.count).to(equal(1))
//
//                    expect({
//                        guard case DecodingError.keyNotFound(let key, let context)? = errors?.first else {
//                            return .failed(reason: "The error should be of type 'DecodingError.keyNotFound'")
//                        }
//
//                        expect(key.stringValue).to(equal("identifier"))
//                        expect(context.debugDescription).to(
//                            equal("""
//                            No value associated with key CodingKeys(stringValue: "identifier", intValue: nil) ("identifier").
//                            """)
//                        )
//                        return .succeeded
//                    }).to(succeed())
//                }
//            }
//        }
//    }
//
//    func test_givenInvalidEntries() {
//        describe("GIVEN a file with invalid articles") {
//            let filename = "invalid-articles"
//            var sut: ArticleList?
//
//            context("WHEN we decode the associated data") {
//                beforeEach {
//                    do {
//                        let data = try self.fileReader.get(filename: filename)
//                        sut = try self.decoder.decode(ArticleList.self, from: data)
//                    } catch {
//                        fail("An error occured: \(error)")
//                    }
//                }
//
//                it("THEN we should have no entries and two errors") {
//                    expect(sut).toNot(beNil())
//                    expect(sut?.articles).to(beEmpty())
//
//                    let errors = sut?.$articles.errors
//                    expect(errors?.count).to(equal(2))
//
//                    expect({
//                        guard case DecodingError.typeMismatch(let type, let context)? = errors?.first else {
//                            return .failed(reason: "The error should be of type 'DecodingError.typeMismatch'")
//                        }
//
//                        expect("\(type)").to(equal("Int"))
//                        expect(context.debugDescription).to(
//                            equal("Expected to decode Int but found a string/data instead.")
//                        )
//                        return .succeeded
//                    }).to(succeed())
//
//                    expect({
//                        guard case DecodingError.keyNotFound(let key, let context)? = errors?.last else {
//                            return .failed(reason: "The error should be of type 'DecodingError.keyNotFound'")
//                        }
//
//                        expect(key.stringValue).to(equal("title"))
//                        expect(context.debugDescription).to(
//                            equal("""
//                            No value associated with key CodingKeys(stringValue: "title", intValue: nil) ("title").
//                            """)
//                        )
//                        return .succeeded
//                    }).to(succeed())
//                }
//            }
//        }
//    }
//
//    func test_givenNullEntry() {
//        describe("GIVEN a file with null articles") {
//            let filename = "null-articles"
//            var sut: ArticleList?
//
//            context("WHEN we decode the associated data") {
//                beforeEach {
//                    do {
//                        let data = try self.fileReader.get(filename: filename)
//                        sut = try self.decoder.decode(ArticleList.self, from: data)
//                    } catch {
//                        fail("An error occured: \(error)")
//                    }
//                }
//
//                it("THEN we should have no entries and no error") {
//                    expect(sut).toNot(beNil())
//                    expect(sut?.articles).to(beEmpty())
//                    expect(sut?.$articles.errors).to(beEmpty())
//                }
//            }
//        }
//    }
//
//    func test_givenMissingKey() {
//        describe("GIVEN a file with null articles") {
//            let filename = "missing-articles-key"
//            var sut: ArticleList?
//
//            context("WHEN we decode the associated data") {
//                beforeEach {
//                    do {
//                        let data = try self.fileReader.get(filename: filename)
//                        sut = try self.decoder.decode(ArticleList.self, from: data)
//                    } catch {
//                        fail("An error occured: \(error)")
//                    }
//                }
//
//                it("THEN we should have no entries and no error") {
//                    expect(sut).toNot(beNil())
//                    expect(sut?.articles).to(beEmpty())
//                    expect(sut?.$articles.errors).to(beEmpty())
//                }
//            }
//        }
//    }

// test_givenInvalidValue (type)
//}
