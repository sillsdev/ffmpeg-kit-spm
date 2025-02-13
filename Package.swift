// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.9.1"

let frameworks = ["ffmpegkit": "9d3851abb80121233b93c27107cc9739bc0f1320d6f561e348c37d724b5114db", "libavcodec": "11edaf5e22ee1a2bf61982b740f19b8f1ccdf5bde16b7fd4dad81b5fe3eff1f2", "libavdevice": "73dddb1c5351e162e487c7c1f9176996d4d53d37d22527d1d2cc60fb8d495b42", "libavfilter": "eac5ff27f22379680d5462ae24e80f9e7c9d9004b9d0aabef4a085eff772d738", "libavformat": "fcc4661c6aba49bf4089ded4c500fda8f3099f1b9bf5de116c3c5102f6bf7afc", "libavutil": "4c38e01c3e35db0e50abe5bd51f7a5758c71806222a4396ae724a8299d2ac870", "libswresample": "58d04ba747de99b369316980d80bcb210e8f475f26a4aace7dce97f31f2fbd2e", "libswscale": "334e1897accef5bc5fc6b41e01b6a75abce0f6e79e5c5247d9389ed46d920840"]

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
