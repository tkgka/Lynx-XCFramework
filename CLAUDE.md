# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Lynx-Xcframework — [Lynx](https://lynxjs.org) iOS SDK를 **XCFramework로 추출하는 전용 프로젝트**.
Lynx는 CocoaPods로만 배포되므로, pod 산출물을 아카이브해 XCFramework로 재패키징하고
SPM `binaryTarget` / Tuist xcframework 의존성으로 소비할 수 있게 만드는 것이 이 저장소의 유일한 목적이다.

- 앱 프로젝트가 아니다. `Lynx-XcFramework` 타깃은 **framework** 타깃이며, 아카이브 시 모든 pod가 함께 빌드되게 하는 앵커 역할이다.
- 저장소 루트가 곧 SPM 패키지다: `Package.swift`가 8개 바이너리(`Lynx_XcFramework` 제외)를
  `binaryTarget`으로 선언하고 `Lynx` 라이브러리 제품 하나로 묶어 노출한다.
- 바이너리는 저장소에 커밋하지 않고 **GitHub Release 자산**으로 배포한다. 릴리스는
  `.github/workflows/`의 두 워크플로가 만든다 (아래 Distribution 참고).
- 파이프라인 상세 / 버전 업그레이드 / SPM 배포 절차: `docs/EXTRACTION.md`

## Commands

```zsh
# 최초 1회 (Pods/는 git-ignored)
pod install

# XCFramework 추출 — device(arm64) + simulator(arm64/x86_64) (기본, 수 분 소요)
./build.sh

PLATFORMS=sim ./build.sh      # 시뮬레이터 슬라이스만 (빠른 반복용 — 소비 측 실기기 빌드는 깨짐)
PLATFORMS=device ./build.sh   # 실기기 슬라이스만
SIGN_IDENTITY= ./build.sh     # 코드사인 생략 (기본 identity: TFLQDNW4Z9)
INCLUDE_DSYM=1 ./build.sh     # dSYM 동봉 (산출물 77MB → ~860MB)
REUSE_ARCHIVE=1 ./build.sh    # 기존 build/*.xcarchive 재사용, xcframework 재생성만 수행
SLIM_HEADERS=0 ./build.sh     # PrivateHeaders 유지 (기본은 제거)

# 산출물 슬라이스 확인 (build.sh가 끝에 자동 출력하는 것과 동일)
for f in Results/*.xcframework; do echo "$f:"; ls "$f" | grep ios; done

# SPM 매니페스트 검증 (Results/ 재추출 후)
swift package dump-package > /dev/null && echo OK

# 배포 스크립트 (CI가 사용, 로컬 실행도 가능)
scripts/latest-pod-version.sh Lynx          # CocoaPods trunk 최신 정식 버전 조회
scripts/set-lynx-version.sh 3.9.0           # Podfile의 Lynx 버전 갱신 (나머지는 pod update가 해석)
scripts/make-manifest.sh 3.9.0 <owner/repo> # Results/ → dist/*.zip + url:checksum: Package.swift 생성

# devtool 플레이버 — Lynx DevTool 데스크톱에 연결되는 배포판 (아래 Devtool flavor)
scripts/build-devtool.sh                    # devtool/에서 pod install|update → Results-devtool/ (12개)
PLATFORMS=device scripts/build-devtool.sh   # 실기기만 (DevTool 데스크톱은 USB 실기기 연결)
MANIFEST_REPO=<owner/repo> scripts/build-devtool.sh   # + dist-devtool/{*.zip, Package.swift} (태그 <버전>-devtool)
```

- 아카이브 로그: `build/ios_device.log`, `build/ios_sim.log` (실패 시 여기부터 확인)
- 테스트/린트는 없다. 검증 = build.sh 성공 + 슬라이스 확인 + 소비 측 빌드 통과.

## Architecture

전체 흐름 (build.sh가 자동화):

```
Podfile (버전 고정)
  → pod install                       # Pods/ 생성 (post_install이 Lynx C/C++ 소스에
                                      #  -fvisibility=hidden 부착)
  → xcodebuild archive ×2             # generic/platform=iOS, iOS Simulator
                                      # BUILD_LIBRARY_FOR_DISTRIBUTION=YES, 서명 없음
                                      # 크기 최적화(-Oz / -Osize / thin LTO / strip) 적용
  → xcrun xcodebuild -create-xcframework   # 프레임워크별 device+sim 슬라이스 병합
  → PrivateHeaders 제거 (SLIM_HEADERS=1, 기본)
  → codesign (완성된 xcframework에만)
  → Results/*.xcframework             # 8개
```

앵커 타깃 `Lynx-XcFramework`(소스는 `Lynx-XcFramework/Anchor.swift` 하나)은 아카이브에서 모든 pod가
함께 빌드되게 하는 역할만 하고, 그 산출물은 xcframework로 만들지 않는다 — 소비 측에 불필요하고
`MACH_O_TYPE=staticlib`이라 LTO 하에서는 `create-xcframework`가 실패한다.

**크기 최적화**: 아카이브 시 `-Oz`(`GCC_OPTIMIZATION_LEVEL=z`), Swift `-Osize` + wholemodule,
thin LTO, dead code stripping, `-fvisibility-inlines-hidden`(`CLANG_CXX_INLINES_HIDDEN`),
심볼 스트립(`STRIP_STYLE=non-global`)을 xcodebuild CLI 인자로 넘겨 모든 pod 타깃에 강제 적용한다.
`STRIP_STYLE`을 `all`로 올리거나 `GCC_SYMBOLS_PRIVATE_EXTERN`(Symbols Hidden by Default)을
**모든 타깃에** 켜면 프레임워크 간 심볼 링크와 ObjC 클래스 export가 깨진다 — 대신 Lynx 엔진의
C/C++ 소스에만 파일 단위로 거는 방식을 쓴다 (아래 **심볼 가시성**).

**심볼 가시성**(`HIDE_SYMBOLS=1`, 기본): Podfile의 `post_install`이 **Lynx 타깃의 `.cc`/`.c`/`.cpp`
파일에만** `-fvisibility=hidden`을 붙이고, xcconfig의 `EXPORT_SYMBOLS_FOR_DEVTOOL`을 0으로 내린다.
Lynx 소스(`core/base/lynx_export.h`)는 원래 `-fvisibility=hidden` 전제로 공개 API에만
`LYNX_EXPORT`를 붙여 두었는데 podspec에 그 설정이 빠져 있어, 4.0.1 arm64 기준 export 심볼
11,580개 중 10,171개가 엔진 내부 C++ 심볼이다(`LYNX_EXPORT` 주석은 80개뿐). 그래서 `__LINKEDIT`이
1.84MB로 부풀고 `DEAD_CODE_STRIPPING`/thin LTO도 전부 루트로 잡혀 아무것도 못 지운다.
경계 조건 세 가지를 지켜야 한다:
- **`.m`/`.mm`은 제외** — ObjC 클래스 심볼도 hidden 되는데, 소비 측이 쓰는 `LynxUI`,
  `LynxPropsProcessor`, `LynxCustomMeasureShadowNode`, `LynxNativeLayoutNode`,
  `AlignParam`/`MeasureParam`, `LynxColorUtils`, `DevToolOverlayDelegate` 8개가 `.mm`에 있다.
- **Lynx 타깃에만 적용** — Lynx가 LynxBase/PrimJS의 C++ 심볼 375개(`lynx::base::logging::*`,
  `Napi::*`)를 프레임워크 경계 너머로 쓴다. 반대 방향(Lynx의 C++ 심볼을 밖에서 참조)은
  LynxService/LynxServiceAPI/소비 측 모두 0건이다.
- 되돌리려면 `HIDE_SYMBOLS=0 pod update` 후 재빌드.

**PrivateHeaders 제거**(`SLIM_HEADERS=1`, 기본): xcframework 완성 후 서명 직전에
슬라이스별 `PrivateHeaders/`를 지운다. 어느 프레임워크에도 `module.private.modulemap`이 없어
모듈로는 노출되지 않는 헤더들이고(Lynx 909개 6.3MB, LynxBase 137개 1.7MB, 슬라이스당 ~8MB),
앱 바이너리 크기와 무관한 순수 배포 용량이다 — `Lynx.xcframework.zip` 13.98 → 10.93MB.
`@import Lynx`는 제거 전후 모두 정상 컴파일된다(실측). public 헤더 4개
(`LynxContext+Internal.h`, `LynxBackgroundRuntime+Internal.h`, `LynxTemplateData+Converter.h`,
`LynxUIRendererProtocol.h`)가 `#if defined(__cplusplus)` 안에서 private 헤더를 include하지만
`core/shell/ios/js_proxy_darwin.h`처럼 소스트리 상대경로라 flat한 `PrivateHeaders/` 레이아웃에서는
제거 전에도 해석되지 않는다 — 즉 소비 측에서 도달할 수 없는 헤더였다.
그래도 문제가 생기면 `SLIM_HEADERS=0`으로 끈다.

바이너리 링크 그래프 (otool -L 기준, 화살표 = "링크한다"):

```
Lynx                → LynxBase, LynxServiceAPI, PrimJS
LynxService         → Lynx, SDWebImage, SDWebImageWebPCoder
SDWebImageWebPCoder → libwebp
```

`Podfile`은 **Lynx 버전만 고정**한다 (iOS 12.0). PrimJS / LynxService / SDWebImage 등 나머지
pod의 버전은 podspec 의존성 제약을 `pod update`가 해석해 `Podfile.lock`에 기록한다
(예: Lynx 3.6.0 → PrimJS/quickjs 3.6.1, Lynx 3.9.0 → PrimJS/quickjs 3.8.0-alpha.6 — 정확 고정이라
손으로 버전을 맞추면 안 된다). 버전 변경 후에는 `pod install`이 아니라 `pod update`를 쓴다 —
install은 이전 `Podfile.lock`에 잠긴 버전을 요구사항으로 합류시켜 충돌한다.
Podfile의 `post_install`은 pod 소스별 `-Werror`를 제거하고(아래), Lynx 타깃의 C/C++ 소스에
`-fvisibility=hidden`을 붙인다(위 **심볼 가시성**). `-Werror` 제거는 —
새 Xcode의 clang이 경고를 추가할 때마다 빌드가 깨지는 것을 막는다 (예: Xcode 26.5의
`-Wnontrivial-memcall`).

## Important Notes

- **device 슬라이스는 필수다.** 시뮬레이터 슬라이스만 배포하면 소비 측 실기기 빌드가
  `building for iOS, but linking in object file built for iOS Simulator`로 실패한다.
  `PLATFORMS=sim`은 로컬 반복용으로만 쓴다.
- 서명은 아카이브 단계에서 생략하고(`CODE_SIGNING_ALLOWED=NO`) 완성된 xcframework에만 한다.
  프레임워크 추출이 목적이므로 아카이브 서명은 불필요하다.
- Lynx는 C++ 기반이라 module stability가 완전하지 않다. `BUILD_LIBRARY_FOR_DISTRIBUTION`이
  실패하면 옵션을 빼고 Xcode 버전을 고정해 빌드한다 (소비 측 Xcode 버전 일치 필요).
- 새 pod 버전으로 올릴 때: `Podfile` 버전 수정 → `pod update` → `./build.sh` → 슬라이스 확인
  → 소비 측에 복사 후 빌드 검증 (`docs/EXTRACTION.md`의 체크리스트).
- 바이너리·중간 산출물(`Results/`, `dist/`, `Pods/`, `build/`, `.build/`)은 전부 git-ignored다.
  배포는 GitHub Release zip으로만 한다.
- `Package.swift`는 릴리스 시 `scripts/make-manifest.sh`가 `url:checksum:` 기반으로 재생성해
  커밋한다 — **직접 수정하지 말 것.** 로컬 개발 중에는 `.binaryTarget(path: "Results/…")`로
  바꿔 써도 되지만 커밋하지 않는다.
- 프레임워크 추가/제거는 `build.sh`와 `scripts/make-manifest.sh`의 `FRAMEWORKS` 배열을
  함께 수정한다. devtool 플레이버가 더하는 프레임워크는 `scripts/build-devtool.sh`의
  `DEVTOOL_FRAMEWORKS`와 Podfile의 `LYNX_DEVTOOL` 분기에 있다.

## Devtool flavor

`scripts/build-devtool.sh`는 [Lynx DevTool](https://github.com/lynx-family/lynx-devtool) 데스크톱에
연결할 수 있는 배포판을 만든다. 릴리스 파이프라인(`build.sh`)을 그대로 타되 세 가지가 다르다:

- **pod 구성**: Podfile의 `LYNX_DEVTOOL=1` 분기가 `LynxDevtool`(Lynx와 같은 버전, `Framework`
  서브스펙), `BaseDevtool`, `DebugRouter`(+`MessageTransceiverEnable`, 기본 5.0.15 —
  `DEBUG_ROUTER_VERSION`), `LynxService`의 `Devtool` 서브스펙을 더한다. `LynxDevtool/Framework`가
  `SocketRocket`과 PrimJS의 `quickjs_debugger`/`profiler` 서브스펙을 끌어오므로 PrimJS 바이너리도
  달라진다. lynxjs.org "Integrating Lynx DevTool"(iOS)의 Podfile과 같은 구성이다.
- **심볼**: `HIDE_SYMBOLS`와 `EXPORT_SYMBOLS_FOR_DEVTOOL=0` 패치를 끈다 — LynxDevtool이
  Lynx의 `LYNX_EXPORT_FOR_DEVTOOL` 심볼과 inspector 훅을 프레임워크 경계 너머로 링크한다.
  그래서 기본 8개 프레임워크도 **릴리스판과 다른 바이너리**다. 섞어 쓰지 않는다.
- **격리**: `devtool/Podfile`이 루트 Podfile을 `LYNX_DEVTOOL=1`로 `eval`하고, 앵커 프로젝트 사본·
  `Pods/`·워크스페이스·`Podfile.lock`은 `devtool/`에 생긴다(앵커 사본·Pods·워크스페이스는 git-ignored,
  `devtool/Podfile.lock`은 커밋). 산출물은 `Results-devtool/`, `build-devtool/`, `dist-devtool/`.
  루트 `Podfile.lock`·`Package.swift`·`Results/`는 건드리지 않는다. 기본은 서명하지 않는다
  (`SIGN_IDENTITY=…`로 켠다).

Lynx 버전은 루트 Podfile의 `pod 'Lynx', '<버전>'` 줄 하나에서 읽는다(`LYNX_VERSION`) — devtool pod이
같은 버전을 따라간다. 스크립트는 `devtool/Podfile.lock`의 Lynx 버전이 루트와 다르면 `pod update`,
같으면 `pod install`을 돈다. 끝에 네 프레임워크와 `LynxDebugResources.bundle`(LogBox·스위치 페이지)
존재, Lynx export 심볼 중 devtool 관련 개수를 찍는다.

배포는 릴리스 워크플로 밖이다. `MANIFEST_REPO=<owner/repo>`를 주면 `dist-devtool/`에 zip 12개와
`Lynx` + `LynxDevtool` 두 제품을 선언한 `Package.swift`가 생긴다(태그 `<Lynx 버전>-devtool`, 예
`4.2.0-devtool`). 별도 브랜치에서 그 파일을 루트 `Package.swift`로 복사·커밋하고 태그를 붙인 뒤 zip을
Release 자산으로 올린다. 소비 측은 `exact: "4.2.0-devtool"`로 받아 DEV 구성에만 `LynxDevtool` 제품을
링크하고, 앱에서 `LynxEnv.prepareDevToolForDevelopmentBeforeInit()` → `LynxEnv.sharedInstance()` →
`devtoolEnabled = true`(+`logBoxEnabled`)를 켠다. 프로덕션에는 넣지 않는다(패키지 크기, 디버그 포트).
`LynxDevtool/LynxRecorder`와 Lynx `-dev` 배포판(Trace/Recorder)은 범위 밖이다.

## Distribution (GitHub Actions)

2단계 릴리스 흐름 — 버전 업 PR(수동) → 머지 시 빌드/릴리스(자동):

- `auto-update-lynx.yml` (**Bump Lynx Version (PR)** — 수동 실행): 입력한 버전(비우면 CocoaPods
  최신)으로 Podfile을 갱신하는 PR을 올린다 (`bump-lynx-<버전>` 브랜치). Podfile이 이미 그
  버전이거나 같은 브랜치의 열린 PR이 있으면 건너뛴다.
  저장소 설정 필요: Settings → Actions → General →
  **"Allow GitHub Actions to create and approve pull requests"** 활성화.
- `update-lynx.yml` (**Build & Release XCFramework** — main에 Podfile 변경이 push되면 실행,
  버전 업 PR 머지 포함): Podfile에 고정된 버전으로 `pod update` → `build.sh` → zip/checksum →
  `Package.swift` 재생성 → `Podfile.lock`/`Package.swift` 커밋 → 버전 태그로 GitHub Release
  생성 + zip 업로드. 같은 버전 릴리스가 이미 있으면 건너뛴다. 실패 시 `build/*.log`가
  artifact(`build-logs`)로 남는다. xcframework 서명은 secrets(`SIGNING_CERTIFICATE_P12`,
  `P12_PASSWORD`, `KEYCHAIN_PASSWORD`)의 인증서를 임시 키체인에 설치해 수행하며, secret이
  없으면 서명 없이 빌드한다 (`docs/EXTRACTION.md` §4).
- 릴리스 태그 = Lynx 버전 (예: `3.9.0`). 나머지 pod 버전은 `pod update`가 podspec 제약으로
  해석하며, 릴리스 노트에 `Podfile.lock` 기준 전체 버전 목록이 기록된다.
- 봇이 GITHUB_TOKEN으로 푸시하는 매니페스트 커밋은 워크플로를 재트리거하지 않는다 (루프 없음).
- 저장소를 GitHub에 처음 push하면 diff가 없는 push로 간주되어 Build & Release가 1회 실행되고,
  현재 Podfile 버전의 부트스트랩 릴리스가 만들어지면서 `Package.swift`가 url 기반으로 교체된다.

## Git Conventions

- Commit format: `type: Korean description` (e.g., `chore: Lynx 3.8.0으로 버전 업`)
- Types: `feat`, `fix`, `perf`, `refactor`, `chore`, `docs`, `test`
- Do NOT include `Co-Authored-By` in commit messages
