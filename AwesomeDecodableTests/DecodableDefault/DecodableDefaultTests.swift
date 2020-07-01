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
