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
let feature = try JSONDecoder().decode(Feature.self, from: json)

print(feature.identifier) // true
print(feature.$isEnable.error) // LosslessValue.DecodingError.unsupportedType
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
let feature = try JSONDecoder().decode(Feature.self, from: json)

print(feature.identifier) // false
print(feature.$isEnable.error) // LosslessValue.DecodingError.unsupportedType
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
    @LosslessValue.Experimental
    var description: String
}
```

## DecodableDefault

`DecodableDefault` allows to define a default value for `Decodable` types that will be applied if the decoding process fails.

This wrapper is used by defining a strategy (`DecodableDefaultStrategy`) that lets you define the type of the `Decodable` property  with its default value.

It will fallback to its default value if the associated coding key is not present, if the associated value is 'null' or of an invalid type.

### Strategies
There is already a set of strategies ready for you to use. You will find them in `DecodableDefault.Strategies` enum.
You can also use your own if you want a custom behavior.

#### True
Sets the value to `true` if the decoding process fails.

```swift
fileprivate struct Feature: Decodable {
    @DecodableDefault.True
    private(set) var isEnable: Bool
}

let json = #"{ "isEnable": false }"#.data(using: .utf8)!
let feature = try JSONDecoder().decode(Feature.self, from: json)

print(feature.isEnable) // false

let json = #"{ "isEnable": null }"#.data(using: .utf8)!
let feature = try JSONDecoder().decode(Feature.self, from: json)

print(feature.isEnable) // true
```

#### False
Sets the value to `false` if the decoding process fails.

```swift
fileprivate struct Feature: Decodable {
    @DecodableDefault.False
    private(set) var isEnable: Bool
}

let json = #"{ "isEnable": true }"#.data(using: .utf8)!
let feature = try JSONDecoder().decode(Feature.self, from: json)

print(feature.isEnable) // true

let json = #"{ "isEnable": null }"#.data(using: .utf8)!
let feature = try JSONDecoder().decode(Feature.self, from: json)

print(feature.isEnable) // false
```

#### EmptyString
Sets the value to an empty string if the decoding process fails.

```swift
fileprivate struct User: Decodable {
    @DecodableDefault.EmptyString
    private(set) var identifier: String
}

let json = #"{ "identifier": "XTGSKBJHB" }"#.data(using: .utf8)!
let user = try JSONDecoder().decode(User.self, from: json)

print(user.identifier) // XTGSKBJHB

let json = #"{ "identifier": null }"#.data(using: .utf8)!
let user = try JSONDecoder().decode(User.self, from: json)

print(user.identifier) // ""
```

#### EmptyList
Sets the value to an empty array if the decoding process fails.

```swift
fileprivate struct Article: Decodable {
    @LossyDecodableArray
    private(set) var keywords: [String]
}

let json = #"{ "keywords": [ "sports" ] }"#.data(using: .utf8)!
let article = try JSONDecoder().decode(Article.self, from: json)

print(article.keywords) // ["sports"]

let json = #"{ "keywords": null }"#.data(using: .utf8)!
let article = try JSONDecoder().decode(Article.self, from: json)

print(article.keywords) // []
```

#### EmptyMap
Sets the value to an empty map if the decoding process fails.

```swift
fileprivate struct Flight: Decodable {
    @LossyDecodableArray
    private(set) var airports: [String: String]
}

let json = #"{ "airports": [ "LAX": "Los Angeles International Airport" ] }"#.data(using: .utf8)!
let flight = try JSONDecoder().decode(Flight.self, from: json)

print(airports.airports) // ["LAX": "Los Angeles International Airport"]

let json = #"{ "keywords": null }"#.data(using: .utf8)!
let airports = try JSONDecoder().decode(Article.self, from: json)

print(airports.airports) // [:]
```
#### More
To implement your own strategies, please follow this process:

- Add your strategy to the `DecodableDefault.Strategy` enum.

```swift
extension DecodableDefault.Strategies {
    enum UnknownString: DecodableDefaultStrategy {
        public static var defaultValue: String { "Unknown" }
    }
}
```

- Add a typealias in order to access your new strategy easily

```swift
extension DecodableDefault {
    typealias UnknowString = Wrapper<Strategies.UnknownString>
}
```

- Use

```swift
fileprivate struct User {
    @DecodableDefault.UnknowString
    var name: String
}
```

## Thanks

I strongly recommand that you check these links:
- https://www.swiftbysundell.com/tips/default-decoding-values/
- https://github.com/marksands/BetterCodable
