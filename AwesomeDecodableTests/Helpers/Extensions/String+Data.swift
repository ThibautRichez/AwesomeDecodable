//
//  String+Data.swift
//  AwesomeDecodableTests
//
//  Created by RICHEZ Thibaut on 5/25/20.
//  Copyright © 2020 richez. All rights reserved.
//

import Foundation

enum StringDataConversionError: Error {
    case emptyData
}

extension String {
    func data(using encoding: String.Encoding) throws -> Data {
        guard let data = self.data(using: .utf8) else {
            throw StringDataConversionError.emptyData
        }

        return data
    }
}
