// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v5.1.6"

let frameworks = ["ffmpegkit": "287e9bcc936300a2ed40e44ae2ea3bc1a598cc676e8f9d038e2df81e0cb896f3", "libavcodec": "c537c07aef2afa035c5f27696f3a0ad8d9c4e96489709580a2cf0f1bd3e19a9c", "libavdevice": "e2dc44b4e86102ac8c7da8f1fd57b71de9b270fbf0cd5a9ca689bdb5ec7683c2", "libavfilter": "9d3e72092f836b3b9db619b0b1ec3d98683a667a215dafcdfb79e3d5b337cc14", "libavformat": "4fdc79deef4629170f565f12f346a9274067971127f5c9c42ca28b54574dc59b", "libavutil": "7bc324a766b96dc5c62ed3f2eb6ab9fe50ebb06b38b5088d6933b9ac479b6b7c", "libswresample": "152e587c0d15e11f1af8f772826074090ddc15685799b0a818f1bce1d0416cc3", "libswscale": "5add0a0f75841c6fd9e08284c5dc5ad60e674b104b5fcc70f5630978c7cf3966"]

func xcframework(_ package: Dictionary<String, String>.Element) -> Target {
    let url = "https://github.com/davidmoore1/ffmpeg-kit-spm/releases/download/\(release)/\(package.key).xcframework.zip"
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
            linkerSettings: linkerSettings),
        .target(
            name: "FFmpeg",
            dependencies: libAVFrameworks.map { .byName(name: $0.key) },
            linkerSettings: linkerSettings),
    ] + frameworks.map { xcframework($0) }
)
