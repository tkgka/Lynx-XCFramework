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
            checksum: "0b04c4d491f1d265ef81c3cafc002256e03bad4b0629bc1e960d29f3dc3d7d82"
        ),
        .binaryTarget(
            name: "LynxBase",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/LynxBase.xcframework.zip",
            checksum: "8b5e17ae3d172fda6da4bb9ccd22d80f94a5d7956d80a2f8d2f094ff66fc7315"
        ),
        .binaryTarget(
            name: "LynxService",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/LynxService.xcframework.zip",
            checksum: "3811b7b331490207725cf5931a40a4cc7e98b46253b3a5a4b946d064766b9260"
        ),
        .binaryTarget(
            name: "LynxServiceAPI",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/LynxServiceAPI.xcframework.zip",
            checksum: "c157b87f39e5e0ebd3bcfdf453c3d9989dd0ab3a7178e94840d7aa55bc680abe"
        ),
        .binaryTarget(
            name: "PrimJS",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/PrimJS.xcframework.zip",
            checksum: "07e4c13649a6ddc6f5cec0b673d5b56527c0cc3a4fe679d5d5cd0da72b42856f"
        ),
        .binaryTarget(
            name: "SDWebImage",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/SDWebImage.xcframework.zip",
            checksum: "350f2e3d426f06032d65b790fa4a4d52c4ffe359ef96fc5a9805dc05cd3f1376"
        ),
        .binaryTarget(
            name: "SDWebImageWebPCoder",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/SDWebImageWebPCoder.xcframework.zip",
            checksum: "d040e575d28a6f99a0d70e01add6e1e054363b54dd83ad90131c09fe74dbfb77"
        ),
        .binaryTarget(
            name: "libwebp",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/libwebp.xcframework.zip",
            checksum: "b6db366de123a85dd5430ace46c1cc4750aac56bc704bc3f2dba36ec5584968f"
        ),
    ]
)
