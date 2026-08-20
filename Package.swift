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
            checksum: "56536ba6fc0b6eb7f7cf19213e2b83c4cde915636249d9e91b524526174b10a6"
        ),
        .binaryTarget(
            name: "LynxBase",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/LynxBase.xcframework.zip",
            checksum: "fa8d9cafc7658c3f5a8af10d0a76959e3f325be439c56552195b01839b1ee5f2"
        ),
        .binaryTarget(
            name: "LynxService",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/LynxService.xcframework.zip",
            checksum: "cd6a71dfd4f151446d263ca19ae88452c9bff4856a1e792b13239b2baf6bcce8"
        ),
        .binaryTarget(
            name: "LynxServiceAPI",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/LynxServiceAPI.xcframework.zip",
            checksum: "8120b41ad4e30ba5c6506b89ad6576ac447e1236f14c31024040be8259b3cdc1"
        ),
        .binaryTarget(
            name: "PrimJS",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/PrimJS.xcframework.zip",
            checksum: "93e92cf59a4e813c47e2f53f5b2b554ce9e246718ee8d6963123f9efe8d78702"
        ),
        .binaryTarget(
            name: "SDWebImage",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/SDWebImage.xcframework.zip",
            checksum: "15788bd9a60c6f680f01d2e45634cedfddeb30dd25dcb5640bca0431c2cb1675"
        ),
        .binaryTarget(
            name: "SDWebImageWebPCoder",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/SDWebImageWebPCoder.xcframework.zip",
            checksum: "9578099410682191edf34a022db4723c14a46540a9c91c03437886fcc2ae0f99"
        ),
        .binaryTarget(
            name: "libwebp",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.1/libwebp.xcframework.zip",
            checksum: "4479a3e89a463155ae5f3df51e59c21edbbbf5e622893c8269971d81d6f1f0af"
        ),
    ]
)
