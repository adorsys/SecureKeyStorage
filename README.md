# Secure Device Storage - iOS

## Introduction

With Keychain Services Apple already provides functionality to securely store sensitive data, such as keys and login tokens, on an iOS device. Nevertheless the keychain is only secure if the user has a device passcode set. According to Apple 89% percent of the users have their device secured with a passcode (as of June 2016, see https://developer.apple.com/videos/play/wwdc2016/705/ 14:31 min). For devices with no passcode set there has to be provided another option to securely store sensitive data on an iOS device.

### Keychain security (device passcode required)

The iOS Keychain is a SQLite database stored in the filesystem of the iOS device. The filesystem is encrypted in the Secure Enclave coprocessor that is fabricated in the Apple A7 (or later) processor. Thus it is available on iPhone 5s, iPad Air, iPad mini 2 and later devices. As the encryption is tied to the hardware (Secure Enclave), possible attacks have to performed on the specific device.

The keychain provides different classes of protection levels. To ensure that the data is secure, it is required to use the protection class `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`. When using this class, the data is only stored in the keychain when the user has a device passcode set. When the user removes or resets the passcode, the keys to decrypt the data are discarded and the data can't be accessed any more.

It is also possible to set policies for accessibility and authentication. Access to a keychain item can be limited unless the user authenticated using passcode or TouchID.

One can't find a size limitation for keychain items in Apple's documentation. Nevertheless only small amounts of data, like keys or login tokens, should be saved to the keychain. To securely store larger amounts of data, it's recommended to encrypt it with a key, store the encrypted data on the filesystem and only save the key in the keychain.

### Secure Storage without device passcode

For devices that are not protected with a passcode there needs to be a different way to securely safe the data as keychain items can't be protected by passcode/TouchID.

## Usage

## Further reading

iOS security guide:
https://www.apple.com/business/docs/iOS_Security_Guide.pdf

WWDC 2016 session on iOS security:
https://developer.apple.com/videos/play/wwdc2016/705/

Apple documentation of keychain services:
https://developer.apple.com/library/content/documentation/Security/Conceptual/keychainServConcepts/02concepts/concepts.html
