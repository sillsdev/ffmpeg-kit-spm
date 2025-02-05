// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.5.1"

let frameworks = ["ffmpegkit": "2e2218a3b47a82ee1908dab5b9eb243b0331d6559e97121043500c0e69ed85c4", "libavcodec": "f7dd9b5e7950bd152cbe207e3d1390f1e2986f54da6def9968156ccf122e9f79", "libavdevice": "911fce55aefc1df2576a10cd7a11f3fda6b9302f572781598640117d00312f6a", "libavfilter": "b5be7fbe16a4443eda63b264653c21cdff3e030bba1ef966100eb82153198696", "libavformat": "84fc3ee7a0d2678f817e87387b5f00bd7b87f769b56411206b642cc41b252f3f", "libavutil": "062cd3d77fc5f8cb7a5147e92974513d9d5af0c86b90974d2722fa604d4624e4", "libswresample": "601cac5c54e1a605e4f13cfc677a7efee0b1375ec8134ef203c4f4e4b1a92599", "libswscale": "5ea2c60ea64bf484ec3c05b76a9ee1a299e476b643b9e5d75efd663a9c2a464b"]

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
