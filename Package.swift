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
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.0.1/Lynx.xcframework.zip",
            checksum: "cb49887416ad3fbea69e7fde246a9baf55db224e96b8d6314f2d16da79980820"
        ),
        .binaryTarget(
            name: "LynxBase",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.0.1/LynxBase.xcframework.zip",
            checksum: "fb01f0ca962e4641ccfd1632edc44d5d0a2cd5947d8c131b625a4963b0f323ec"
        ),
        .binaryTarget(
            name: "LynxService",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.0.1/LynxService.xcframework.zip",
            checksum: "b9daf526b106231b104d54d03b1594210455e78f9e66844367f156b56f16a0b4"
        ),
        .binaryTarget(
            name: "LynxServiceAPI",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.0.1/LynxServiceAPI.xcframework.zip",
            checksum: "63e14bfb062191888e49bd769ba8d688ac43f1b7152fe5946893f0eb09396dd4"
        ),
        .binaryTarget(
            name: "PrimJS",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.0.1/PrimJS.xcframework.zip",
            checksum: "7a79074c6e00756047df49f1274595f2b6f31722bd4414b98da32bf0cfada800"
        ),
        .binaryTarget(
            name: "SDWebImage",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.0.1/SDWebImage.xcframework.zip",
            checksum: "661576db27803b97c1107974c21c21408becdd71c29fae1796377da7ca93ada3"
        ),
        .binaryTarget(
            name: "SDWebImageWebPCoder",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.0.1/SDWebImageWebPCoder.xcframework.zip",
            checksum: "bf56bfac69bd895665ef63f09156b95dbaac8cc13ca96f6804c158bd00507b6a"
        ),
        .binaryTarget(
            name: "libwebp",
            url: "https://github.com/tkgka/Lynx-XCFramework/releases/download/4.0.1/libwebp.xcframework.zip",
            checksum: "caeedb72f520b1af2c25e4ca632d6aa370a9f3eb1e8c27d87edae5c76af79490"
        ),
    ]
)
