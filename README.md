# SimpleCoders

## Description
This repository includes some useful tools for `Codable` protocol and data decoding.

## Usage

1. `PlainCodingKey` 

Simple `CodingKey` struct.

2. Type reflection for `Decodable` types

```swift
let properties: [String: Any.Type] = Mirror.reflect(SomeType.self)
//or Mirror(SomeType.self).children
``` 
9. Tools for creating custom encoders/decoders

Based on similar logic when writing different encoders/decoders `DecodingUnboxer` and `EncodingBoxer` protocols were implemented.
Examples of usage are all encoders in decoders in this repo.

## Installation
1. [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.
```swift
// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/SimpleCoders.git", from: "1.4.0")
    ],
  targets: [
    .target(name: "SomeProject", dependencies: ["SimpleCoders"])
    ]
)
```
```ruby
$ swift build
```
2.  [CocoaPods](https://cocoapods.org)

Add the following line to your Podfile:
```ruby
pod 'SimpleCoders'
```
and run `pod update` from the podfile directory first.

## Author

Voidilov, voidilov@gmail.com

## License

VDCodable is available under the MIT license. See the LICENSE file for more info.
