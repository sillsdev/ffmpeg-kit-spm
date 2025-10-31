// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v5.1.13"

let frameworks = ["ffmpegkit": "cfcd0c00fbbd6222fa37afbad30000988cfd339bd2aa67cc091dbad7f51b8014", "libavcodec": "223231571e79de02703734cef01cf85985f796bb4abd97f55bb2e30db2726dfd", "libavdevice": "2d2b67d0b19deeea4029906314c4e4959a5aba2f2bb9779025d5e85d7838bb8a", "libavfilter": "4e992aded999a59d7c75869f4fb01d4d595c48bf580de9c7e6d8fc7dcae68ecb", "libavformat": "e8dae2ba40e94833e7ec4cc62d491c858bde18f485eae5b93837e31b45aabda1", "libavutil": "b767ca548ff5a58f410e0b05f832f9634c8d9a2d80004d0911ecf716fcc27fc2", "libswresample": "4e7ff5fba8e14e6862706268b87d1aa586ae6658a0d581e3367a5d765c35fe11", "libswscale": "94d373a2157937a0b29b56b7d9d08dfea3b3ac1a5896c2048a59e8bda41c0365"]

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
    platforms: [.iOS(.v15), .macOS(.v10_15), .tvOS(.v11), .watchOS(.v7)],
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
