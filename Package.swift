import PackageDescription

let package = Package(
    name: "ADSecureDeviceStorage",
    dependencies: [
        .Package(url: "https://github.com/RNCryptor/RNCryptor", "5.0.1")
    ]
)
