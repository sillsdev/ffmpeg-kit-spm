// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v5.1.12"

let frameworks = ["ffmpegkit": "521c08b5b885e1be17a8eb676d8cf4cd3125763671c6bc49d3dfa61cbf0aa941", "libavcodec": "58c135b9587f92835ec9a7a6a49bffe1b8bc0cf480e60e6072cb507c34a36153", "libavdevice": "7b22e4d7d3790fa8c6b5f81987004c4cc97396aa4cc89d5b91f916f8e0c3985f", "libavfilter": "5af7631a53303ea8b3781b7d4a8b4255146bfd5556d2c2858283eebae7b1afa8", "libavformat": "584bd6e961c3d9f377c1b879485dcb672935138f115735d61b18521001ced223", "libavutil": "a653a4b81e06aa7986146bc3ba7c3b084a2d4040f2be9e982ace48dfd14515b6", "libswresample": "65c4e282f690c7d5faf2ba2dfa2864e3390c5d665b2d2ed4a7cea1ce382313e0", "libswscale": "998bbb50e8a4a43ebb55e83373f7f16e612e138b58fea2504c21519dc5e0cb94"]

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
    platforms: [.iOS(.v15_6), .macOS(.v10_15), .tvOS(.v11), .watchOS(.v7)],
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
