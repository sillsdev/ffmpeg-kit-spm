// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v5.1.10"

let frameworks = ["ffmpegkit": "adafe9c9443c66030e79928f783c3b4c15e5ca7354d3d7877c182274d1d24980", "libavcodec": "6a7772749e94ec506ed974968f662aa268ad2bc357c25f576c1e9fec7c5918b2", "libavdevice": "c7150f6b23dd8a30a1f2f3bf7ab914700541b4defd14d0d9ae2e0c67641b5f38", "libavfilter": "5570bc1093b1e7e71377ee292575a834af45ded97e0dc9e463d7e65a81b8d647", "libavformat": "584a647a9b08b2608e1b214df5cef431a915b95f308ed76eb9526bdab879d533", "libavutil": "a9b227621fa37dea7e851aa4fd52fdadd6e4d859762b19c3c7062acf01beaa0a", "libswresample": "af1868d4b93f93aa468a3fc64d8bbc16080de84dd3939a57f4c3ca832c680cf6", "libswscale": "25d9b142264faf02d157f4d15744f442f35ac885cd8243b807c28bbfc14e02a4"]

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
