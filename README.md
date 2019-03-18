# SecureKeyStorage - iOS

[![Build Status](https://travis-ci.com/adorsys/SecureKeyStorage.svg?branch=master)](https://travis-ci.com/adorsys/SecureKeyStorage.svg?branch=master)
[![Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg)](https://swift.org)
[![license](https://img.shields.io/badge/license-Apache_2.0-lightgrey.svg)](https://github.com/adorsys/SecureKeyStorage/blob/master/LICENSE)
[![platform](https://img.shields.io/badge/platform-iOS_9+-lightgrey.svg)](https://img.shields.io/badge/platform-iOS_9+-lightgrey.svg)

SecureKeyStorage – a pod for storing sensitive data securely on iOS devices.

- [Requirements](#requirements)
- [Installation](#installation)
  - [CocoaPods](#cocoapods)
- [Introduction](#introduction)
  - [Keychain Security (Device Passcode required)](#keychain-security-device-passcode-required)
  - [Secure Storage without Device Passcode](#secure-storage-without-device-passcode)
- [Usage](#usage)
  - [Keychain Store](#keychain-store)
    - [Save String](#save-string)
    - [Obtain String](#obtain-string)
  - [Encrypted Store](#encrypted-store)
    - [Save Data](#save-data)
    - [Obtain Data](#obtain-data)
- [Further reading](#further-reading)
- [License](#license)

## Requirements
- iOS 9.0 SDK or later

## Installation

### CocoaPods

SecureKeyStorage is available through [CocoaPods](http://cocoapods.org).
To install it, simply add the following line to your `Podfile`:

```ruby
pod 'SecureKeyStorage', :git => 'https://github.com/adorsys/SecureKeyStorage.git'
```

## Introduction

With Keychain Services Apple already provides functionality to securely store sensitive data, such as keys and login tokens, on an iOS device. Nevertheless the keychain is only secure, if the user has a device passcode set. According to Apple, 89% percent of the users have their device secured with a passcode (as of June 2016, see https://developer.apple.com/videos/play/wwdc2016/705/, 14:31 min). For devices with no passcode set, there has to be provided another option to securely store sensitive data on an iOS device.

### Keychain Security (Device Passcode required)

The iOS Keychain is a SQLite database stored in the filesystem of the iOS device. The filesystem is encrypted in the Secure Enclave coprocessor that is fabricated in the Apple A7 (or later) processor. Thus it is available on iPhone 5s, iPad Air, iPad mini 2 and later devices. As the encryption is tied to the hardware (Secure Enclave), possible attacks have to be performed on the specific device.

The keychain provides different classes of protection levels. To ensure that the data is secure, it is required to use the protection class `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`. When using this class, the data is only stored in the keychain when the user has a device passcode set. When the user removes or resets the passcode, the keys to decrypt the data are discarded and the data can't be accessed any more.

It is also possible to set policies for accessibility and authentication. Access to a keychain item can be limited unless the user authenticated using passcode or TouchID.

One can't find a size limitation for keychain items in Apple's documentation. Nevertheless only small amounts of data, like keys or login tokens, should be saved to the keychain. To securely store larger amounts of data, it's recommended to encrypt it with a key, store the encrypted data on the filesystem and only save the key in the keychain.

### Secure Storage without Device Passcode

For devices that are not protected with a passcode, there needs to be a different way to securely safe the data as keychain items can't be protected by passcode/TouchID. The sensitive data has to be encrypted "manually" using password based encryption. For doing that, the [RNCryptor](https://github.com/RNCryptor/RNCryptor) framework is used, which is a wrapper for Common Crypto Library.

To encrypt sensitive data on devices that are not secured by a passcode a random encryption key is created. The sensitive data is encrypted with that key and saved to the keychain or filesystem. The encryption key itself is encrypted with a password, the user has to set in the application. For that purpose a key is derived from that password, using `PBKDF2`. The encryption is done with `AES-256`.

## Usage

It is possible to store `String` and `Data`. You can access all features with `import SecureKeyStorage`.

### Keychain Store

How to use a keychain store with user presence protected items.

#### Save String

```swift
let keychainStore = SecureKeyStorage.keychainStore()
try? keychainStore?.save("Secret Token", for: "secretTokenKey")
```

#### Obtain String

This operation requires an authentication of the user. Thus is must be run on a background thread.

```swift
DispatchQueue.global().async {
  let keychainStore = SecureKeyStorage.keychainStore()
  let secret = try? keychainStore?.getString(for: "secretTokenKey")
}
```

### Encrypted Store

How use the encrypted store to protect items by a password.

#### Save Data

```swift
let secureStore = SecureKeyStorage.encryptedStore(password: "geheim", user: "username")
if let data = "Secret Token".data(using: .utf8) {
  try? secureStore.save(data, for: "secretTokenKey")
}
```

#### Obtain Data

```swift
let secureStore = SecureKeyStorage.encryptedStore(password: "geheim", user: "username")
let data = try? secureStore.getData(for: "secretTokenKey")
```

## Further reading

- iOS security guide:
https://www.apple.com/business/docs/iOS_Security_Guide.pdf
- WWDC 2016 session on iOS security:
https://developer.apple.com/videos/play/wwdc2016/705/
- Apple documentation of keychain services:
https://developer.apple.com/library/content/documentation/Security/Conceptual/keychainServConcepts/02concepts/concepts.html
- RNCryptor framework:
https://github.com/RNCryptor/RNCryptor

## License

SecureKeyStorage is released under the **Apache 2.0 License**. Please see the [LICENSE](https://github.com/adorsys/SecureKeyStorage/blob/master/LICENSE) file for more information.
