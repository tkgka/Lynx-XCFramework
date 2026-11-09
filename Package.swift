// swift-tools-version: 5.9
//
// ⚠️ scripts/make-manifest.sh가 생성하는 파일 — 직접 수정하지 말 것.
// 바이너리는 GitHub Release(4.2.0) 자산을 가리킨다.
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
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.2.0/Lynx.xcframework.zip",
            checksum: "bbb9d3d17096d51db3513c1dd4c51ccc34982995ca6a3f3f3d12c891eae49ea5"
        ),
        .binaryTarget(
            name: "LynxBase",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.2.0/LynxBase.xcframework.zip",
            checksum: "325745ef5aa6aa2fe9045ac78dbd1b38d03753d612a79e390dbe3ef3d51b290e"
        ),
        .binaryTarget(
            name: "LynxService",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.2.0/LynxService.xcframework.zip",
            checksum: "aba37f182d3cc0ae75e9d1cde0b8afdc83e0ae3b0867e8a8218e6daa465c0a45"
        ),
        .binaryTarget(
            name: "LynxServiceAPI",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.2.0/LynxServiceAPI.xcframework.zip",
            checksum: "dc0e02a9a11d4cdc3020a863c3a8705c7e7c4adbdbc5b3b86510a5a428206c6c"
        ),
        .binaryTarget(
            name: "PrimJS",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.2.0/PrimJS.xcframework.zip",
            checksum: "0868a7b6343b8ee0acd9118fc86ddd7912c95ffe998acc5a5c51127b0ab1f82b"
        ),
        .binaryTarget(
            name: "SDWebImage",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.2.0/SDWebImage.xcframework.zip",
            checksum: "992b026aeee8ff24c29ff0bad70b31c447f6ef5bc1b5b8d55da75a0bbd8302a3"
        ),
        .binaryTarget(
            name: "SDWebImageWebPCoder",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.2.0/SDWebImageWebPCoder.xcframework.zip",
            checksum: "cc9a24b8526df7d76d59da818d9d430063293056bd11865d2db80ac5b939a0d9"
        ),
        .binaryTarget(
            name: "libwebp",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.2.0/libwebp.xcframework.zip",
            checksum: "c3fc38f67e0b835f4f49d6a52f098641f6156ad394473104bc6a3a07b15ec63c"
        ),
    ]
)
