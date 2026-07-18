// swift-tools-version: 5.9
//
// ⚠️ scripts/make-manifest.sh가 생성하는 파일 — 직접 수정하지 말 것.
// 바이너리는 GitHub Release(3.9.0) 자산을 가리킨다.
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
            url: "https://github.com/xenonClient/Lynx-XcFramework/releases/download/3.9.0/Lynx.xcframework.zip",
            checksum: "8b284cb8b8a1391eaeb89dccdbcd3d13108561a34bf00f67fbc468d4acc39d4a"
        ),
        .binaryTarget(
            name: "LynxBase",
            url: "https://github.com/xenonClient/Lynx-XcFramework/releases/download/3.9.0/LynxBase.xcframework.zip",
            checksum: "27f70e8cee8254884a624d26b110f1b3631608da18b3350a9d88279403f43d7a"
        ),
        .binaryTarget(
            name: "LynxService",
            url: "https://github.com/xenonClient/Lynx-XcFramework/releases/download/3.9.0/LynxService.xcframework.zip",
            checksum: "4aa97a345498ab43922c5adcf53e6645c1110c9675916cce4ca6982adaa2087b"
        ),
        .binaryTarget(
            name: "LynxServiceAPI",
            url: "https://github.com/xenonClient/Lynx-XcFramework/releases/download/3.9.0/LynxServiceAPI.xcframework.zip",
            checksum: "e755b481a19aa05a94cfcca9cd4e6c8a1188bd755f297d4a5d05113a76a566ed"
        ),
        .binaryTarget(
            name: "PrimJS",
            url: "https://github.com/xenonClient/Lynx-XcFramework/releases/download/3.9.0/PrimJS.xcframework.zip",
            checksum: "0d185b49f5a1a16c85932f07a4b43b787546eca0f15051995169866755202333"
        ),
        .binaryTarget(
            name: "SDWebImage",
            url: "https://github.com/xenonClient/Lynx-XcFramework/releases/download/3.9.0/SDWebImage.xcframework.zip",
            checksum: "7d004da9c1e94911657ebfb512b4c60efd64c593f0acfe0e6b12ff6be3c220ee"
        ),
        .binaryTarget(
            name: "SDWebImageWebPCoder",
            url: "https://github.com/xenonClient/Lynx-XcFramework/releases/download/3.9.0/SDWebImageWebPCoder.xcframework.zip",
            checksum: "add24e56dfd3002a8bdb757af2b3833f5b64ceb1bc2a5977c21f9102b8805b09"
        ),
        .binaryTarget(
            name: "libwebp",
            url: "https://github.com/xenonClient/Lynx-XcFramework/releases/download/3.9.0/libwebp.xcframework.zip",
            checksum: "d75ddee06dd59c3ad637b47aff241ba6bd88c5a268db17e1d9820ce30680a94e"
        ),
    ]
)
