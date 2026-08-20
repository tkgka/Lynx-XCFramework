// swift-tools-version: 5.9
//
// ⚠️ scripts/make-manifest.sh가 생성하는 파일 — 직접 수정하지 말 것.
// 바이너리는 GitHub Release(4.0.1) 자산을 가리킨다.
import PackageDescription

let package = Package(
    name: "Lynx",
    platforms: [.iOS(.v12)],
    products: [
        // 바이너리 간 전이 링크가 자동으로 걸리지 않으므로 제품 하나로 전부 묶는다
        .library(
            name: "Lynx",
            targets: [
                "Lynx",
                "LynxBase",
                "LynxService",
                "LynxServiceAPI",
                "PrimJS",
                "SDWebImage",
                "SDWebImageWebPCoder",
                "libwebp",
            ]
        )
    ],
    targets: [
        .binaryTarget(
            name: "Lynx",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/Lynx.xcframework.zip",
            checksum: "aaad2c25daa71c5040d3cee385910c1a8334ef9f89780c2aed56f988e42beae8"
        ),
        .binaryTarget(
            name: "LynxBase",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/LynxBase.xcframework.zip",
            checksum: "d070080bfd4e6f85237416c49232d107ca85d8e944a9ad675ff7b9666c329a46"
        ),
        .binaryTarget(
            name: "LynxService",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/LynxService.xcframework.zip",
            checksum: "c976a2048b3db1f88681a13c55dd0857cf74965e4c10968d0da5df62452b7605"
        ),
        .binaryTarget(
            name: "LynxServiceAPI",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/LynxServiceAPI.xcframework.zip",
            checksum: "5e4a0ad9725e37e83392096a0d9f6f7abe7c8e2c5b3cc10bbad5c3e7b63492ed"
        ),
        .binaryTarget(
            name: "PrimJS",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/PrimJS.xcframework.zip",
            checksum: "a6cd602d9447d3d22faaddf632e6fa26a8aaf7ed0b35021e71b5ef305e657def"
        ),
        .binaryTarget(
            name: "SDWebImage",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/SDWebImage.xcframework.zip",
            checksum: "df02607f92d089b2d1ad4a3bca3278eab2d76cae1ca478f95f93b1a938d8b409"
        ),
        .binaryTarget(
            name: "SDWebImageWebPCoder",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/SDWebImageWebPCoder.xcframework.zip",
            checksum: "5243c2b8eadca38a00b2f6baddb4ab19557f4053d63191ca150e5cfdea5e3170"
        ),
        .binaryTarget(
            name: "libwebp",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/libwebp.xcframework.zip",
            checksum: "7168a3e314305b69f3cc58ef0dbec514776351da037b01939d03bda336b3c2e9"
        ),
    ]
)
