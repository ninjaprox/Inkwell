# Inkwell

[![CI Status](http://img.shields.io/travis/ninjaprox/Inkwell.svg?style=flat)](https://travis-ci.org/ninjaprox/Inkwell)
[![Version](https://img.shields.io/cocoapods/v/Inkwell.svg?style=flat)](http://cocoapods.org/pods/Inkwell)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Inkwell.svg?style=flat)](http://cocoapods.org/pods/Inkwell)
[![Platform](https://img.shields.io/cocoapods/p/Inkwell.svg?style=flat)](http://cocoapods.org/pods/Inkwell)

## Introduction

In brief, _Inkwell_ is a font library to use custom fonts on the fly. _Inkwell_ takes responsibilities for:
- [x] Downloading fonts from Google Fonts or custom resources.
- [x] Registering custom fonts to the system.
- [x] Loading and using custom fonts dynamically and seamlessly.

## Example

To run the example project, clone the repo, and run `pod install` from the `Example` directory first.

![alt tag](https://raw.githubusercontent.com/ninjaprox/Inkwell/master/Demo.gif)

## Installation

### CocoaPods

Install [CocoaPods](https://cocoapods.org) if need be.

```bash
$ gem install cocoapods
```

Add `Inkwell` in your `Podfile`.

```ruby
use_frameworks!

pod 'Inkwell'
```

Run the following command.

```bash
$ pod install
```
### Carthage

Install [Carthage](https://github.com/Carthage/Carthage) if need be.

```bash
$ brew update
$ brew install carthage
```

Add `Inkwell` in your `Cartfile`.

```ruby
github "ninjaprox/Inkwell"
```

Run `carthage` to build the framework and drag the built `Inkwell.framework` into your Xcode project.

## Usage

Firstly, set the Google API key in the app delegate.

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    Inkwell.shared.APIKey = "paste your key here"
}
```

Now you are ready to use _Inkwell_ with only one API to remember.

```swift
let font = Font(family: "ABeeZee" variant: .regular)
let fontSize = 27
Inkwell.shared.font(for: font, size: fontSize) { uifont in
    // Do something with the `uifont`.
}
```

_**Note:** Do not forget to `import Inkwell` in any file using Inkwell._

## Documentation

For full API documentation, please check [Inkwell's documentation](http://cocoadocs.org/docsets/Inkwell).

## Dependency

- [Alamofire](https://github.com/Alamofire/Alamofire)

## License

_Inkwell_ is available under the MIT license. See the [LICENSE](https://github.com/ninjaprox/Inkwell/blob/master/LICENSE) file for more info.

Copyright (c) 2017 Vinh Nguyen [@ninjaprox](http://twitter.com/ninjaprox)
