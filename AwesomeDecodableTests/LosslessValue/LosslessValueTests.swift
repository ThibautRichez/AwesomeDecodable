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

/// A Strategy that defines that the expected type is `Int` but should try
/// to decode the data as a `String` also.
/// If the decoding process fails, the property value will be `0`
fileprivate struct IntOrStringDecodingStrategy: LosslessStringDecodingStrategy {
    static var defaultValue: Int = 0
    static var supportedTypes: [LosslessStringDecodable.Type] = [String.self]
}

fileprivate typealias DefaultIntLosslessValue = LosslessValue<IntOrStringDecodingStrategy>

fileprivate struct User: Decodable, Equatable {
    let name: String

    @DefaultIntLosslessValue
    private(set) var age: Int
}

class LosslessValueTests: QuickSpec {
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

            self.test_givenValidEntry()
            self.test_givenEntryWithAgeAsValidString()
            self.test_givenEntryWithAgeAsInvalidString()
            self.test_givenEntryWithAgeAsBool()
            self.test_givenEntryWithNullAge()
            self.test_givenMissingAge()
        }
    }
}

private extension LosslessValueTests {
    func test_givenValidEntry() {
        describe("GIVEN a file with valid user entry") {
            let filename = "valid-user"
            var sut: User?

            let expectedUser = User(name: "Thibaut Richez", age: 25)

            context("WHEN we decode the associated data") {
                beforeEach {
                    do {
                        let data = try self.fileReader.get(filename: filename)
                        sut = try self.decoder.decode(User.self, from: data)
                    } catch {
                        fail("An error occured: \(error)")
                    }
                }

                it("THEN it should have the right value") {
                    expect(sut).toNot(beNil())
                    expect(sut).to(equal(expectedUser))

                    expect(sut?.$age.error).to(beNil())
                }
            }
        }
    }

    func test_givenEntryWithAgeAsValidString() {
        describe("GIVEN a file with user entry with a valid String as the age") {
            let filename = "user-valid-string-age"
            var sut: User?

            let expectedUser = User(name: "Thibaut Richez", age: 25)

            context("WHEN we decode the associated data") {
                beforeEach {
                    do {
                        let data = try self.fileReader.get(filename: filename)
                        sut = try self.decoder.decode(User.self, from: data)
                    } catch {
                        fail("An error occured: \(error)")
                    }
                }

                it("THEN it should have the right value because the string case is handle by IntOrStringDecodingStrategy") {
                    expect(sut).toNot(beNil())
                    expect(sut).to(equal(expectedUser))

                    expect(sut?.$age.error).to(beNil())
                }
            }
        }
    }

    func test_givenEntryWithAgeAsInvalidString() {
        describe("GIVEN a file with user entry with an invalid String as the age") {
            let filename = "user-invalid-string-age"
            var sut: User?

            let expectedUser = User(name: "Thibaut Richez", age: 25)

            context("WHEN we decode the associated data") {
                beforeEach {
                    do {
                        let data = try self.fileReader.get(filename: filename)
                        sut = try self.decoder.decode(User.self, from: data)
                    } catch {
                        fail("An error occured: \(error)")
                    }
                }

                it("THEN it should have the right name and the default age") {
                    expect(sut).toNot(beNil())
                    expect(sut).toNot(equal(expectedUser))
                    expect(sut?.name).to(equal(expectedUser.name))
                    expect(sut?.age).to(equal(IntOrStringDecodingStrategy.defaultValue))

                    expect({
                        guard case LosslessValueDecodingError.invalidValue(let value, let type)? = sut?.$age.error else {
                            return .failed(reason: "The error should be of type 'invalidValue'")
                        }

                        expect(value).to(equal("I'm not convertible to a number"))
                        expect("\(type)").to(equal("Int"))
                        return .succeeded
                    }).to(succeed())
                }
            }
        }
    }

    func test_givenEntryWithAgeAsBool() {
        let filename = "user-bool-age"
        var sut: User?

        let expectedUser = User(name: "Thibaut Richez", age: 25)

        context("WHEN we decode the associated data") {
            beforeEach {
                do {
                    let data = try self.fileReader.get(filename: filename)
                    sut = try self.decoder.decode(User.self, from: data)
                } catch {
                    fail("An error occured: \(error)")
                }
            }

            it("THEN it should have the right name and the default age because bool case is not handle by IntOrStringDecodingStrategy and is not convertible to Int") {
                expect(sut).toNot(beNil())
                expect(sut).toNot(equal(expectedUser))
                expect(sut?.name).to(equal(expectedUser.name))
                expect(sut?.age).to(equal(IntOrStringDecodingStrategy.defaultValue))

                expect({
                    guard case LosslessValueDecodingError.unsupportedType(let types)? = sut?.$age.error else {
                        return .failed(reason: "The error should be of type 'unsupportedType'")
                    }

                    expect(types.map { "\($0)" }).to(equal(["String"]))
                    return .succeeded
                }).to(succeed())
            }
        }
    }

    func test_givenEntryWithNullAge() {
        let filename = "user-null-age"
        var sut: User?

        let expectedUser = User(name: "Thibaut Richez", age: 25)

        context("WHEN we decode the associated data") {
            beforeEach {
                do {
                    let data = try self.fileReader.get(filename: filename)
                    sut = try self.decoder.decode(User.self, from: data)
                } catch {
                    fail("An error occured: \(error)")
                }
            }

            it("THEN it should have the right name and the default age") {
                expect(sut).toNot(beNil())
                expect(sut).toNot(equal(expectedUser))
                expect(sut?.name).to(equal(expectedUser.name))
                expect(sut?.age).to(equal(IntOrStringDecodingStrategy.defaultValue))

                expect(sut?.$age.error).to(beNil())
            }
        }
    }

    func test_givenMissingAge() {
        let filename = "user-missing-age"
        var sut: User?

        let expectedUser = User(name: "Thibaut Richez", age: 25)

        context("WHEN we decode the associated data") {
            beforeEach {
                do {
                    let data = try self.fileReader.get(filename: filename)
                    sut = try self.decoder.decode(User.self, from: data)
                } catch {
                    fail("An error occured: \(error)")
                }
            }

            it("THEN it should have the right name and the default age") {
                expect(sut).toNot(beNil())
                expect(sut).toNot(equal(expectedUser))
                expect(sut?.name).to(equal(expectedUser.name))
                expect(sut?.age).to(equal(IntOrStringDecodingStrategy.defaultValue))

                expect(sut?.$age.error).to(beNil())
            }
        }

    }
}
