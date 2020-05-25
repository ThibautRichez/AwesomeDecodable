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

fileprivate struct User: Decodable, Equatable {
    let firstname: String
    let lastname: String
}

fileprivate struct Users: Decodable, Equatable {
    let users: [User]
}

class LossyDecodableArrayTests: QuickSpec {
    override func spec() {
        self.test_givenValidEntries()
    }

    func test_givenValidEntries() {
        describe("GIVEN a file with valid users entries") {
            let filename = "valid-users"
            context("WHEN we decode the associated data") {
                it("THEN it should have the right values") {
                    expect {
                        let data = try FileReader.get(filename: filename)
                        return try JSONDecoder.default.decode(Users.self, from: data)
                    }.to(equal(
                        Users(users: [User(firstname: "toto", lastname: "tata")])
                    ))
                }
            }
        }
    }
}
