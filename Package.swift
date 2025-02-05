// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v5.1.7"

let frameworks = ["ffmpegkit": "5082d4db9eeda2de7d7a9c099a7bbebf8f2b531ff8edb186676587b9929af620", "libavcodec": "7d1237889fc7c29b544c7a81fbe74cb161b4bf2b52f0e5cbdd10554ab6c3e459", "libavdevice": "e58665e53deff56ca2306aa71661e2466ee1f22de71fbe53c7595251011e7c18", "libavfilter": "c09858d8b6d5b01013f15524b00f1509de752ccad9fcd09b18e8b933dab936ab", "libavformat": "5baedd0308f98261db05068e6dd64e21d09cfc8c45411141e40653944e56737a", "libavutil": "1f420981a4de9d6333285811223bab6a20bdc87f2094d3b0bcda6b23ea12607b", "libswresample": "5311a9ac9ae27ca37e331b530e442cc309ab088d50bcddf6b6ca61a861eb518c", "libswscale": "678c8bcbf9bfbc017e5db7e7d2a0629b39d9dabc6be9af1c919fe3ea4cf6b392"]

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
