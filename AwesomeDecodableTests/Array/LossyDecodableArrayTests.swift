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
    let identifier: Int
    let title: String
}

fileprivate struct ArticleList: Decodable, Equatable {
    @LossyDecodableArray
    private(set) var articles: [Article] = []
}

class LossyDecodableArrayTests: QuickSpec {
    private var fileReader: FileReader!
    private var decoder: JSONDecoder!

    override func spec() {
        describe("GIVEN a file reader and a decoder") {
            beforeEach {
                self.fileReader = FileReader()
                self.decoder = JSONDecoder()
            }

            afterEach {
                self.fileReader = nil
                self.decoder = nil
            }

            self.test_givenValidEntries()
            self.test_givenOneInvalidEntry()
            self.test_givenInvalidEntries()
            self.test_givenNullEntry()
            self.test_givenMissingKey()
        }
    }
}

private extension LossyDecodableArrayTests {
    func test_givenValidEntries() {
        describe("GIVEN a file with valid article entries") {
            let filename = "valid-articles"
            var sut: ArticleList?

            let firstExpectedArticle = Article(identifier: 122, title: "I am the first article")
            let lastExepectedArticle = Article(identifier: 54, title: "I am sadly the last one")

            context("WHEN we decode the associated data") {
                beforeEach {
                    do {
                        let data = try self.fileReader.get(filename: filename)
                        sut = try self.decoder.decode(ArticleList.self, from: data)
                    } catch {
                        fail("An error occured: \(error)")
                    }
                }

                it("THEN we should have every entries and no error") {
                    expect(sut).toNot(beNil())
                    expect(sut?.articles.count).to(equal(2))
                    expect(sut?.articles.first).to(equal(firstExpectedArticle))
                    expect(sut?.articles.last).to(equal(lastExepectedArticle))

                    expect(sut?.$articles.errors).to(beEmpty())
                }
            }
        }
    }

    func test_givenOneInvalidEntry() {
        describe("GIVEN a file with one invalid article") {
            let filename = "one-invalid-article"
            var sut: ArticleList?

            let expectedArticle = Article(identifier: 1, title: "I'm the only valid one")

            context("WHEN we decode the associated data") {
                beforeEach {
                    do {
                        let data = try self.fileReader.get(filename: filename)
                        sut = try self.decoder.decode(ArticleList.self, from: data)
                    } catch {
                        fail("An error occured: \(error)")
                    }
                }

                it("THEN we should have only one entry and an error") {
                    expect(sut).toNot(beNil())
                    expect(sut?.articles.count).to(equal(1))
                    expect(sut?.articles.first).to(equal(expectedArticle))

                    let errors = sut?.$articles.errors
                    expect(errors?.count).to(equal(1))

                    expect({
                        guard case DecodingError.keyNotFound(let key, let context)? = errors?.first else {
                            return .failed(reason: "The error should be of type 'DecodingError.keyNotFound'")
                        }

                        expect(key.stringValue).to(equal("identifier"))
                        expect(context.debugDescription).to(
                            equal("""
                            No value associated with key CodingKeys(stringValue: "identifier", intValue: nil) ("identifier").
                            """)
                        )
                        return .succeeded
                    }).to(succeed())
                }
            }
        }
    }

    func test_givenInvalidEntries() {
        describe("GIVEN a file with invalid articles") {
            let filename = "invalid-articles"
            var sut: ArticleList?

            context("WHEN we decode the associated data") {
                beforeEach {
                    do {
                        let data = try self.fileReader.get(filename: filename)
                        sut = try self.decoder.decode(ArticleList.self, from: data)
                    } catch {
                        fail("An error occured: \(error)")
                    }
                }

                it("THEN we should have no entries and two errors") {
                    expect(sut).toNot(beNil())
                    expect(sut?.articles).to(beEmpty())

                    let errors = sut?.$articles.errors
                    expect(errors?.count).to(equal(2))

                    expect({
                        guard case DecodingError.typeMismatch(let type, let context)? = errors?.first else {
                            return .failed(reason: "The error should be of type 'DecodingError.typeMismatch'")
                        }

                        expect("\(type)").to(equal("Int"))
                        expect(context.debugDescription).to(
                            equal("Expected to decode Int but found a string/data instead.")
                        )
                        return .succeeded
                    }).to(succeed())

                    expect({
                        guard case DecodingError.keyNotFound(let key, let context)? = errors?.last else {
                            return .failed(reason: "The error should be of type 'DecodingError.keyNotFound'")
                        }

                        expect(key.stringValue).to(equal("title"))
                        expect(context.debugDescription).to(
                            equal("""
                            No value associated with key CodingKeys(stringValue: "title", intValue: nil) ("title").
                            """)
                        )
                        return .succeeded
                    }).to(succeed())
                }
            }
        }
    }

    func test_givenNullEntry() {
        describe("GIVEN a file with null articles") {
            let filename = "null-articles"
            var sut: ArticleList?

            context("WHEN we decode the associated data") {
                beforeEach {
                    do {
                        let data = try self.fileReader.get(filename: filename)
                        sut = try self.decoder.decode(ArticleList.self, from: data)
                    } catch {
                        fail("An error occured: \(error)")
                    }
                }

                it("THEN we should have no entries and no error") {
                    expect(sut).toNot(beNil())
                    expect(sut?.articles).to(beEmpty())
                    expect(sut?.$articles.errors).to(beEmpty())
                }
            }
        }
    }

    func test_givenMissingKey() {
        describe("GIVEN a file with null articles") {
            let filename = "missing-articles-key"
            var sut: ArticleList?

            context("WHEN we decode the associated data") {
                beforeEach {
                    do {
                        let data = try self.fileReader.get(filename: filename)
                        sut = try self.decoder.decode(ArticleList.self, from: data)
                    } catch {
                        fail("An error occured: \(error)")
                    }
                }

                it("THEN we should have no entries and no error") {
                    expect(sut).toNot(beNil())
                    expect(sut?.articles).to(beEmpty())
                    expect(sut?.$articles.errors).to(beEmpty())
                }
            }
        }
    }
}
