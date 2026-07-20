// swift-tools-version: 5.9
//
// ⚠️ scripts/make-manifest.sh가 생성하는 파일 — 직접 수정하지 말 것.
// 바이너리는 GitHub Release(4.0.0) 자산을 가리킨다.
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
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.0/Lynx.xcframework.zip",
            checksum: "5e9d77ba9daf3418a3b8a98f166e8146b1902c2e97b6773f59523e79c48aa936"
        ),
        .binaryTarget(
            name: "LynxBase",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.0/LynxBase.xcframework.zip",
            checksum: "26d006d5f730a61179ec3a96c48321af0fc627e5f769608051323f5cbd452e5b"
        ),
        .binaryTarget(
            name: "LynxService",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.0/LynxService.xcframework.zip",
            checksum: "ea93c4c0eccd4d5f682cda6013d0d7913aa1015e504a75693c0cc1127c6ae57f"
        ),
        .binaryTarget(
            name: "LynxServiceAPI",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.0/LynxServiceAPI.xcframework.zip",
            checksum: "9b5dbc5330c1a1987d8ec0be041c2d37602f1ea2c74840597a1b794ca64fc0a1"
        ),
        .binaryTarget(
            name: "PrimJS",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.0/PrimJS.xcframework.zip",
            checksum: "c7da5ed75b7600e760ab05c35405edef2427067c522ff84af45658ee4186ed18"
        ),
        .binaryTarget(
            name: "SDWebImage",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.0/SDWebImage.xcframework.zip",
            checksum: "c999dfeabdf060a966d1d261c9912cc42966a84e666ec79b484963c3d0840d9d"
        ),
        .binaryTarget(
            name: "SDWebImageWebPCoder",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.0/SDWebImageWebPCoder.xcframework.zip",
            checksum: "9f649a759b60ecb669175b19b5da46eb1fc4a14a4dfe2fd79653ba50b87783d2"
        ),
        .binaryTarget(
            name: "libwebp",
            url: "https://github.com/xenonClient/Lynx-XCFramework/releases/download/4.0.0/libwebp.xcframework.zip",
            checksum: "831053c18508d75f5a993087bcdd50a500a485633881dcb251bf8956965d30ab"
        ),
    ]
)
