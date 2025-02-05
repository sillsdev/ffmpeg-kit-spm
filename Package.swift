// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.5.2"

let frameworks = ["ffmpegkit": "a194477ba17eb4de301c2d1869bd772d763cdaf6ce460926f18f8fd0aa84dcab", "libavcodec": "e2f12dbb620cb47cca7b6f30457b45698128457716d582ad61e2327017d55a3b", "libavdevice": "dbf3f59cea7387a70355243ff563c7e8ef1b88ecbc3d1d7afcd2e7915985ab49", "libavfilter": "0e0dc70f75b9290d76b1abb8232b1153611750b82d0406bc5d48f31d0f302401", "libavformat": "8290ee2fa65277e2f1d8bb78e8e4632041b0e193dd76478b6ecc7c3d150bea63", "libavutil": "2bf422de5a3e4dabe573f9caa3bce248f689f21c1838ecace5caa5bd9e3e9f91", "libswresample": "689a9c9282e07e41bb1d47e51daaca47be8d83149a666a029c94036774f4f056", "libswscale": "7cf856b2633868e18ae2fffc54adf638a277e2948a0d19a54fa636c27bab120f"]

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
