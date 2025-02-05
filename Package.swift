// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v5.1.8"

let frameworks = ["ffmpegkit": "3f44018d3a02068de1193596de2ea66bcebeee7ac02e6b95145f03820a8e6102", "libavcodec": "0fefe1165ca034b19017db2872cd49016524a19ea8efabd3307302e289fe3874", "libavdevice": "72b762705270abc6568ac94a3f15b9fd5115a894bb07f648a3a4bf2996b13779", "libavfilter": "9620d3cc21904c30b9988b7a5189f14d4b703fec9cd456a1eaa76ce7cd2f362d", "libavformat": "36b40ebd6590872064403117144dc7677b14fe2fadc3a9588e36ee9241370a88", "libavutil": "ff044b019f83970c69b862fc8b61588d02adebd783c90042a815c49ea6400b31", "libswresample": "613061d804b30ed98b52f13053aa98221699edf44b0fe3e08792612d223219b7", "libswscale": "1e9a870fd285cd6342b962500c5d7f14205853cc937251322f3e5f12f7810fad"]

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
            linkerSettings: linkerSettings),
        .target(
            name: "FFmpeg",
            dependencies: libAVFrameworks.map { .byName(name: $0.key) },
            linkerSettings: linkerSettings),
    ] + frameworks.map { xcframework($0) }
)
