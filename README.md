# Decodable Wrappers

A set of  `PropertyWrapper`s that can ease your life when dealing with `Decodable`.

## @LossyDecodableArray
`@LossyDecodableArray` decodes any `Decodable` array by skipping invalid values.

This is useful for arrays that contain non-optional types and prevents one or multiple badly formated JSON object to result to a global `DecodingError`. This will also set the value to an empty array if the key is not present or if its associated value is 'null'.

You can also inspect if one or multiple errors had happenend by accessing the `$variable.errors` array that will contains `DecodingError`s that occured for each skipped elements.

```swift
fileprivate struct Article: Decodable {
    @LossyDecodableArray
    private(set) var keywords: [String]
}
    
let json = #"{ "keywords": [ "sports", 1 ] }"#.data(using: .utf8)!
let article = try JSONDecoder().decode(Article.self, from: json)
    
print(article.keywords) // ["sports"]
print(article.$keywords.errors) // [.typeMismatch],
                                // "Expected to decode String but found a number instead."
```

## @LosslessValue
`@LosslessValue` decodes values that can be represented by multiple types that conform to `LosslessStringConvertible`.

This is useful when the data is returned with unpredictable types form a provider (APIs). For instance, if an API sends either an `Int` or `String` for a given property.

This wrapper is used by defining a strategy (`LosslessStringDecodingStrategy`) that will let you set a default value if the decoding process fails and the types that the decoder should support.

If the decoding process fails, a default value will be applied. You can inspect if an error had happenend by accessing the `$variable.error` property.

### Strategies
There is already a set of strategies ready for you to use. You will find them in `LosslessValue.Strategies` enum.
You can also use your own if you want a custom behavior.

#### IntOrString
A Strategy that defines that the expected type is `Int` but should try to decode the data as a `String` also. If the decoding process fails, the property value will be `0`

```swift
fileprivate struct User: Decodable {
    @LosslessValue.IntOrString
    private(set) var age: Int
}

let json = #"{ "age": "12" }"#.data(using: .utf8)!
let user = try JSONDecoder().decode(User.self, from: json)

print(user.age) // 12
print(user.$age.error) // nil


let json = #"{ "age": "I'm not a number" }"#.data(using: .utf8)!
let user = try JSONDecoder().decode(User.self, from: json)

print(user.age) // 0
print(user.$age.error) // LosslessValue.DecodingError.invalidValue("I am not a number", type: Int)
```

#### StringOrInt
A Strategy that defines that the expected type is `String` but should try to decode the data as a `Int` also. If the decoding process fails, the property value will be an empty string.

```swift
fileprivate struct User: Decodable {
    @LosslessValue.StringOrInt
    private(set) var identifier: String
}

let json = #"{ "identifier": 123456 }"#.data(using: .utf8)!
let user = try JSONDecoder().decode(User.self, from: json)

print(user.identifier) // "123456"
print(user.$age.error) // nil


let json = #"{ "identifier": ["regular": 123456] }"#.data(using: .utf8)!
let user = try JSONDecoder().decode(User.self, from: json)

print(user.identifier) // ""
print(user.$age.error) // LosslessValue.DecodingError.unsupportedType
```

#### TrueOrString
A Strategy that defines that the expected type is `Bool` but should try to decode the data as a `String` also. If the decoding process fails, the property value will be `true`.

```swift
fileprivate struct Feature: Decodable {
    @LosslessValue.TrueOrString
    private(set) var isEnable: Bool
}

let json = #"{ "isEnable": "false" }"#.data(using: .utf8)!
let feature = try JSONDecoder().decode(Feature.self, from: json)

print(feature.isEnable) // false
print(feature.$isEnable.error) // nil

let json = #"{ "isEnable": 99 }"#.data(using: .utf8)!
let user = try JSONDecoder().decode(Feature.self, from: json)

print(user.identifier) // true
print(user.$age.error) // LosslessValue.DecodingError.unsupportedType
```

#### FalseOrString
A Strategy that defines that the expected type is `Bool` but should try to decode the data as a `String` also. If the decoding process fails, the property value will be `false`.

```swift
fileprivate struct Feature: Decodable {
    @LosslessValue.FalseOrString
    private(set) var isEnable: Bool
}

let json = #"{ "isEnable": "true" }"#.data(using: .utf8)!
let feature = try JSONDecoder().decode(Feature.self, from: json)

print(feature.isEnable) // true
print(feature.$isEnable.error) // nil

let json = #"{ "isEnable": 99 }"#.data(using: .utf8)!
let user = try JSONDecoder().decode(Feature.self, from: json)

print(user.identifier) // false
print(user.$age.error) // LosslessValue.DecodingError.unsupportedType
```

#### More
To implement your own strategies, please follow this process:

- Add your strategy to the `LosslessValue.Strategy` enum.

```swift
extension LosslessValue.Strategies {
    enum ExperimentalStrategy: LosslessStringDecodingStrategy {
        public static var defaultValue: T { ... }
        public static var supportedTypes: [LosslessStringDecodable.Type] { ... }
    }
}
```

- Add a typealias in order to access your new strategy easily

```swift
extension LosslessValue {
    typealias Experimental = Wrapper<Strategies.ExperimentalStrategy>
}
```

- Use

```swift
fileprivate struct Recipe {
    @LosslessValue.LosslessValue
    var description: String
}
```

## DecodableDefault

**WIP**

## Thanks

I strongly recommand that you check these links:
- https://github.com/marksands/BetterCodable
- https://www.swiftbysundell.com/tips/default-decoding-values/
