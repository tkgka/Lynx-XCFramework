#!/bin/bash
#
# devtool 플레이버 빌드 — Lynx DevTool 데스크톱(lynx-family/lynx-devtool)에 연결할 수 있는
# Lynx 배포판을 추출한다. 릴리스 빌드(./build.sh)와 같은 파이프라인을 타되,
#
#   · LynxDevtool · BaseDevtool · DebugRouter · SocketRocket 프레임워크가 더해지고
#     (LynxService에는 Devtool 서브스펙이 들어간다 — Podfile의 LYNX_DEVTOOL 분기),
#   · Lynx 엔진의 심볼 축소(HIDE_SYMBOLS, EXPORT_SYMBOLS_FOR_DEVTOOL=0)가 꺼진다 —
#     LynxDevtool이 그 심볼들을 링크한다.
#
# 그래서 기본 8개 프레임워크도 릴리스판과 **다른 바이너리**다. 산출물은 Results-devtool/에
# 따로 쌓이고, 릴리스 Podfile.lock과 앵커 프로젝트는 건드리지 않는다(devtool/ 작업 디렉토리).
# 프로덕션 앱에 넣지 말 것 — 패키지가 커지고 디버그 포트가 열린다(lynxjs.org 통합 문서의 권고).
#
# 사용법:
#   scripts/build-devtool.sh                    # pod install/update → 아카이브 → Results-devtool/
#   PLATFORMS=device scripts/build-devtool.sh   # 실기기 슬라이스만 (DevTool 데스크톱은 USB 실기기 연결)
#   PLATFORMS=sim scripts/build-devtool.sh      # 시뮬레이터만 (빠른 반복용)
#   REUSE_ARCHIVE=1 scripts/build-devtool.sh    # 기존 build-devtool/*.xcarchive 재사용
#   SIGN_IDENTITY=TFLQDNW4Z9 scripts/build-devtool.sh   # 서명 (기본은 서명하지 않는다 — 로컬 소비용)
#   MANIFEST_REPO=tkgka/Lynx-XCFramework scripts/build-devtool.sh
#       # dist-devtool/에 zip과 Package.swift(제품 Lynx + LynxDevtool)까지 만든다.
#       # 릴리스 태그는 <Lynx 버전>-devtool (예: 4.2.0-devtool) — 아래 "배포" 참고.
#   DEBUG_ROUTER_VERSION=5.0.16 scripts/build-devtool.sh   # DebugRouter 고정 버전 변경 (기본 5.0.15)
#   INCLUDE_DSYM / SLIM_HEADERS 등 build.sh의 옵션은 그대로 통한다.
#
# 배포(선택): dist-devtool/Package.swift는 루트 Package.swift를 덮어쓰지 않는다. devtool 릴리스를
# 만들려면 별도 브랜치에서 그 파일을 루트 Package.swift로 복사해 커밋하고 `<버전>-devtool` 태그를
# 붙인 뒤 dist-devtool/*.zip을 GitHub Release 자산으로 올린다. 소비 측은
# `.package(url:, exact: "4.2.0-devtool")`로 받아 `Lynx`와 `LynxDevtool` 두 제품을 링크한다.
#
set -euo pipefail
cd "$(dirname "$0")/.."

WORKDIR="devtool"
BUILD_DIR="${BUILD_DIR:-./build-devtool}"
OUTPUT_DIR="${OUTPUT_DIR:-./Results-devtool}"
DIST_DIR="${DIST_DIR:-dist-devtool}"
# Podfile의 LYNX_DEVTOOL 분기가 더하는 pod의 프레임워크 이름. Podfile과 함께 고친다.
#   LynxDevtool  — DevTool 에이전트(inspector, CDP), 리소스 번들 LynxDebugResources 동봉
#   BaseDevtool  — LynxDevtool의 기반 (LynxDevtool/Framework 의존)
#   DebugRouter  — 데스크톱과의 USB/WebSocket 연결 (lynx-family/debug-router)
#   SocketRocket — LynxDevtool/Framework가 끌어오는 WebSocket 클라이언트
DEVTOOL_FRAMEWORKS="LynxDevtool BaseDevtool DebugRouter SocketRocket"
# 로컬 소비가 기본이라 서명하지 않는다. 릴리스처럼 서명하려면 SIGN_IDENTITY를 준다.
export SIGN_IDENTITY="${SIGN_IDENTITY-}"
export LYNX_DEVTOOL=1

for tool in pod xcodebuild; do
  command -v "${tool}" > /dev/null || { echo "✗ ${tool}이(가) 없습니다 — macOS + Xcode + CocoaPods가 필요합니다" >&2; exit 1; }
done

LYNX_VERSION="$(sed -nE "s/^ *pod 'Lynx', '([0-9.]+)'.*/\1/p" Podfile)"
[[ -n "${LYNX_VERSION}" ]] || { echo "✗ Podfile에서 Lynx 버전을 읽지 못했습니다" >&2; exit 1; }
echo "▶︎ devtool 플레이버: Lynx ${LYNX_VERSION}, DebugRouter ${DEBUG_ROUTER_VERSION:-5.0.15}"

# 1) 작업 디렉토리 — 앵커 프로젝트 사본. pod install이 프로젝트에 Pods xcconfig와 embed 페이즈를
#    써 넣으므로 루트의 앵커를 공유할 수 없다(릴리스 pod install과 서로 덮어쓴다).
rm -rf "${WORKDIR}/Lynx-XcFramework.xcodeproj" "${WORKDIR}/Lynx-XcFramework"
cp -R Lynx-XcFramework.xcodeproj "${WORKDIR}/"
cp -R Lynx-XcFramework "${WORKDIR}/"
rm -rf "${WORKDIR}/Lynx-XcFramework.xcodeproj/xcuserdata"

# 2) pod install / update — devtool/Podfile.lock이 없거나 루트의 Lynx 버전과 다르면 update
#    (install은 lock에 잠긴 옛 버전을 요구사항으로 합류시켜 충돌한다 — 루트 CLAUDE.md).
locked_version=""
if [[ -f "${WORKDIR}/Podfile.lock" ]]; then
  locked_version="$(sed -nE 's/^  - Lynx \(([0-9.]+)\):?$/\1/p' "${WORKDIR}/Podfile.lock" | head -n1)"
fi
if [[ "${locked_version}" == "${LYNX_VERSION}" ]]; then
  echo "▶︎ pod install (devtool/Podfile.lock = Lynx ${locked_version})"
  (cd "${WORKDIR}" && pod install)
else
  echo "▶︎ pod update (devtool/Podfile.lock: ${locked_version:-없음} → Lynx ${LYNX_VERSION})"
  (cd "${WORKDIR}" && pod update)
fi

# 3) 아카이브 → xcframework. build.sh의 옵션(PLATFORMS, REUSE_ARCHIVE, INCLUDE_DSYM, …)은 환경으로 전달된다.
WORKSPACE="${WORKDIR}/Lynx-XcFramework.xcworkspace" \
BUILD_DIR="${BUILD_DIR}" \
OUTPUT_DIR="${OUTPUT_DIR}" \
EXTRA_FRAMEWORKS="${DEVTOOL_FRAMEWORKS}" \
./build.sh

# 4) 플레이버 검증 — 릴리스판과 달라야 하는 지점이 실제로 달라졌는지.
echo
echo "▶︎ devtool 검증"
status=0
for framework in ${DEVTOOL_FRAMEWORKS}; do
  if [[ -d "${OUTPUT_DIR}/${framework}.xcframework" ]]; then
    echo "  ✓ ${framework}.xcframework"
  else
    echo "  ✗ ${framework}.xcframework 없음" >&2
    status=1
  fi
done
# LogBox · 스위치 페이지 · lynx_core_dev.js가 든 리소스 번들. 없으면 DevTool은 붙어도 LogBox가 비어 있다.
if find "${OUTPUT_DIR}/LynxDevtool.xcframework" -type d -name 'LynxDebugResources.bundle' 2>/dev/null | grep -q .; then
  echo "  ✓ LynxDebugResources.bundle (LynxDevtool.framework 안)"
else
  echo "  ⚠︎ LynxDebugResources.bundle을 찾지 못했습니다 — LogBox/스위치 페이지가 비어 보일 수 있습니다" >&2
fi
# devtool 전용 export가 살아 있어야 LynxDevtool이 Lynx를 링크한다. 슬라이스 하나만 본다.
lynx_binary="$(find "${OUTPUT_DIR}/Lynx.xcframework" -type f -name Lynx -path '*ios-arm64*' 2>/dev/null | head -n1)"
if [[ -n "${lynx_binary}" ]]; then
  devtool_symbols="$(nm -gU "${lynx_binary}" 2>/dev/null | grep -c -i 'devtool' || true)"
  echo "  · Lynx export 심볼 중 devtool 관련: ${devtool_symbols}개 (릴리스판은 0에 가깝다)"
fi
[[ ${status} -eq 0 ]] || exit ${status}

# 5) (선택) zip + Package.swift — 릴리스 매니페스트(루트 Package.swift)는 건드리지 않는다.
if [[ -n "${MANIFEST_REPO:-}" ]]; then
  RESULTS_DIR="${OUTPUT_DIR#./}" \
  DIST_DIR="${DIST_DIR}" \
  EXTRA_FRAMEWORKS="${DEVTOOL_FRAMEWORKS}" \
  MANIFEST_OUT="${DIST_DIR}/Package.swift" \
  scripts/make-manifest.sh "${LYNX_VERSION}-devtool" "${MANIFEST_REPO}"
fi

echo
echo "✅ devtool 플레이버 완료 — ${OUTPUT_DIR}"
echo "   앱 쪽: LynxEnv.prepareDevToolForDevelopmentBeforeInit() 뒤 LynxEnv.sharedInstance().devtoolEnabled = true"
echo "   데스크톱: https://github.com/lynx-family/lynx-devtool (USB로 실기기 연결)"
