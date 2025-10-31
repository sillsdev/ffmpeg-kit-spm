// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v5.1.11"

let frameworks = ["ffmpegkit": "21d6b7a7f1fa52b67a19a14035e4e5885dd4a6163707ce273cbb180704182f65", "libavcodec": "987e86b63993144f6dce95ee31598c4dcfb789eb649f02826b957c004770c21b", "libavdevice": "d6c941b48aaf7b0bf722e3662d785eef2aaeb84469880d942633986002d153e9", "libavfilter": "7e9844b96d726e87749e6a31dff9f39f645e05b6ade617100ba8d789bbb6ce38", "libavformat": "036397d341f5e01d143b77d9b029a24cc935f5026222493d55f5e0173b04d818", "libavutil": "37396885cc02480b7aab3886ca01ad7e3a8e0a8952127517b105f81a77671948", "libswresample": "896e3e961eaf83cd094cce1ffac908d098e321e014886e5a596f2e4cb7a32e79", "libswscale": "f6d8627d1e92239ac2c68ac025da108aae03ef8b744db4248ba51ce694b48e15"]

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
    ] + frameworks.map { .library(name: $0.key, targets: [$0.key]) },
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
