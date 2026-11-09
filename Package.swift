// swift-tools-version: 5.9
//
// ⚠️ scripts/make-manifest.sh가 생성하는 파일 — 직접 수정하지 말 것.
// 바이너리는 GitHub Release(4.2.0-devtool) 자산을 가리킨다.
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
        ,
        // devtool 플레이버 전용 — Lynx DevTool 데스크톱 연결에 필요한 프레임워크.
        // Lynx 제품과 함께 링크하고, 프로덕션 구성에서는 링크하지 않는다.
        .library(
            name: "LynxDevtool",
            targets: [
                "LynxDevtool",
                "BaseDevtool",
                "DebugRouter",
                "SocketRocket",
            ]
        )
    ],
    targets: [
        .binaryTarget(
            name: "Lynx",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.2.0-devtool/Lynx.xcframework.zip",
            checksum: "b722a7ea9fa230d9a906569fbf955742b554ca5a8f253b3dd169aa2f88d89fb9"
        ),
        .binaryTarget(
            name: "LynxBase",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.2.0-devtool/LynxBase.xcframework.zip",
            checksum: "669b26d5d8339a15d45d798b6902dabd6f9ea1be2f02d1b920dfd0eba29afc1e"
        ),
        .binaryTarget(
            name: "LynxService",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.2.0-devtool/LynxService.xcframework.zip",
            checksum: "7eba564822dee36c00f297a6b69e3b01efaab04755ac3380c18956f06c20ca9b"
        ),
        .binaryTarget(
            name: "LynxServiceAPI",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.2.0-devtool/LynxServiceAPI.xcframework.zip",
            checksum: "72740cb4ee4d2e8a2933994cedaf2103f244775da48b25eff52c2dacc7d7c88f"
        ),
        .binaryTarget(
            name: "PrimJS",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.2.0-devtool/PrimJS.xcframework.zip",
            checksum: "a5a128c6034febad76b85246843c9fa5ca846191f58e2c3cca2c9ec3e83033bb"
        ),
        .binaryTarget(
            name: "SDWebImage",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.2.0-devtool/SDWebImage.xcframework.zip",
            checksum: "5936f8e62099747f72e87837a30c2aa934d5ce9605f564d0353287bb508a2406"
        ),
        .binaryTarget(
            name: "SDWebImageWebPCoder",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.2.0-devtool/SDWebImageWebPCoder.xcframework.zip",
            checksum: "5abce8db4919805c7bd792560fa7dde38cad0affe007ccf8d1e4e0e74926b2e9"
        ),
        .binaryTarget(
            name: "libwebp",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.2.0-devtool/libwebp.xcframework.zip",
            checksum: "9329db7b1a3553c0a4713299e6a94d64a8ab15d9adcaae5a6c4b31dd17e8186d"
        ),
        .binaryTarget(
            name: "LynxDevtool",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.2.0-devtool/LynxDevtool.xcframework.zip",
            checksum: "fe89d590c2ff09a4b51dd5e747ce247444e4b5cb7c44ff7bd99fb55a4636c170"
        ),
        .binaryTarget(
            name: "BaseDevtool",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.2.0-devtool/BaseDevtool.xcframework.zip",
            checksum: "57333a921db473c9744d24e74ee37bde64a33c1a2e2c5d4be96c8462e4f4084d"
        ),
        .binaryTarget(
            name: "DebugRouter",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.2.0-devtool/DebugRouter.xcframework.zip",
            checksum: "844d73c8a6657a881f5985c12b8beb1cdb885df0ac749ca8cad376bb68d13025"
        ),
        .binaryTarget(
            name: "SocketRocket",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.2.0-devtool/SocketRocket.xcframework.zip",
            checksum: "8ab9ee0d18365b893bc829d9e9bdf2b16a4ead831f0718fe2fe396a80c1fc36a"
        ),
    ]
)
