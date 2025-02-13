// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v5.1.9"

let frameworks = ["ffmpegkit": "de9502208f25c89480a3f29cfbf537ba946a39a700a87196d01f8715df9c1fe1", "libavcodec": "19e6a12923547c63a9d519cc0e869d7fa1023c4cb9d2b78ac46dc41548a32faf", "libavdevice": "0ae2e7cab50fabc6289f6545058a77e1479bd014861dcc56f27633c2007d09a6", "libavfilter": "1af6e324db0bd808e609b56ac034b2e45811f2b8824c315f010c0e1a6b0d2dd6", "libavformat": "97eb3c332469d163bd0b3f5670014e516ecb740ce9e63cef019146742e3cf9ff", "libavutil": "c0cef4be436914c54bbeeb3f45e8e83ca069628ab1fb1078771ca99f401ad0a0", "libswresample": "f439694f25d65f2d7297d01c03355f2f27a337d01caebcec9d6ee2e1317ed8cd", "libswscale": "bc64ffe4d30bb02dab91094f3b605671c5fac30055f9f1269fa692ae75a40417"]

func xcframework(_ package: Dictionary<String, String>.Element) -> Target {
    let url = "https://github.com/sillsdev/ffmpeg-kit-spm/releases/download/\(release)/\(package.key).xcframework.zip"
    return .binaryTarget(name: package.key, url: url, checksum: package.value)
}

let linkerSettings: [LinkerSetting] = [
    .linkedFramework("AudioToolbox", .when(platforms: [.macOS, .iOS, .macCatalyst, .tvOS])),
    .linkedFramework("AVFoundation", .when(platforms: [.macOS, .iOS, .macCatalyst])),
    .linkedFramework("CoreMedia", .when(platforms: [.macOS])),
    .linkedFramework("OpenGL", .when(platforms: [.macOS])),
    .linkedFramework("VideoToolbox", .when(platforms: [.macOS, .iOS, .macCatalyst, .tvOS])),
    .linkedLibrary("z"),
    .linkedLibrary("lzma"),
    .linkedLibrary("bz2"),
    .linkedLibrary("iconv")
]

let libAVFrameworks = frameworks.filter({ $0.key != "ffmpegkit" })

let package = Package(
    name: "ffmpeg-kit-spm",
    platforms: [.iOS(.v12), .macOS(.v10_15), .tvOS(.v11), .watchOS(.v7)],
    products: [
        .library(
            name: "FFmpeg-Kit",
            type: .dynamic,
            targets: ["FFmpeg-Kit", "ffmpegkit"]),
        .library(
            name: "FFmpeg",
            type: .dynamic,
            targets: ["FFmpeg"] + libAVFrameworks.map { $0.key }),
    ] + libAVFrameworks.map { .library(name: $0.key, targets: [$0.key]) },
    dependencies: [],
    targets: [
        .target(
            name: "FFmpeg-Kit",
            dependencies: frameworks.map { .byName(name: $0.key) },
            linkerSettings: linkerSettings,
            cSettings: [.define("TARGET_UNIVERSAL", to: "1")], // Forces universal build
            swiftSettings: [.define("SUPPORT_SIMULATOR")] // Allows x86_64 support
            ),
        .target(
            name: "FFmpeg",
            dependencies: libAVFrameworks.map { .byName(name: $0.key) },
            linkerSettings: linkerSettings,
            cSettings: [.define("TARGET_UNIVERSAL", to: "1")], // Forces universal build
            swiftSettings: [.define("SUPPORT_SIMULATOR")] // Allows x86_64 support
            ),
    ] + frameworks.map { xcframework($0) }
)
