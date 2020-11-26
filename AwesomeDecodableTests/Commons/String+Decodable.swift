//
//  String+Decodable.swift
//  AwesomeDecodableTests
//
//  Created by RICHEZ Thibaut on 7/1/20.
//  Copyright © 2020 richez. All rights reserved.
//

import Foundation

enum StringDecodableError: Error {
    case dataEncoding(String.Encoding, value: String)
}

extension String {
    func decode<T: Decodable>(using encoding: String.Encoding = .utf8,
                              decoder: JSONDecoder = .init()) throws -> T {
        guard let data = self.data(using: encoding) else {
            throw StringDecodableError.dataEncoding(encoding, value: self)
        }

        return try decoder.decode(T.self, from: data)
    }
}
