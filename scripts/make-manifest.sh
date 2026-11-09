#!/bin/bash
#
# Results/의 xcframework를 zip으로 묶고(dist/), 체크섬을 계산해
# GitHub Release 자산을 가리키는 url/checksum 기반 Package.swift를 생성한다.
#
# 사용법: scripts/make-manifest.sh <version> <owner/repo>
#   예:   scripts/make-manifest.sh 3.6.0 tkgka/Lynx-Xcframework
#
# 플레이버 덮어쓰기(scripts/build-devtool.sh가 쓴다):
#   RESULTS_DIR=Results-devtool DIST_DIR=dist-devtool   # 입력 xcframework / 출력 zip 위치
#   EXTRA_FRAMEWORKS="LynxDevtool BaseDevtool …"        # 기본 8개에 더해 묶을 프레임워크.
#                                                       # 비어 있지 않으면 `LynxDevtool` 제품으로 따로 노출한다
#   MANIFEST_OUT=dist-devtool/Package.swift             # 생성할 매니페스트 경로 (기본 Package.swift)
#
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="$1"
REPO="$2"
BASE_URL="https://github.com/${REPO}/releases/download/${VERSION}"
RESULTS_DIR="${RESULTS_DIR:-Results}"
DIST_DIR="${DIST_DIR:-dist}"
MANIFEST_OUT="${MANIFEST_OUT:-Package.swift}"

# Lynx_XcFramework(추출 앵커 타깃 산출물)은 배포 대상이 아니다
FRAMEWORKS=(
  Lynx
  LynxBase
  LynxService
  LynxServiceAPI
  PrimJS
  SDWebImage
  SDWebImageWebPCoder
  libwebp
)
# 플레이버가 더하는 프레임워크. `Lynx` 제품과 별개의 `LynxDevtool` 제품으로 묶어, 소비 측이
# DEV 구성에서만 링크할 수 있게 한다.
EXTRA=()
if [[ -n "${EXTRA_FRAMEWORKS:-}" ]]; then
  read -r -a EXTRA <<< "${EXTRA_FRAMEWORKS}"
fi
ALL_FRAMEWORKS=("${FRAMEWORKS[@]}" "${EXTRA[@]}")

rm -rf "${DIST_DIR}"
mkdir -p "${DIST_DIR}" "$(dirname "${MANIFEST_OUT}")"

# 1) zip + checksum (Package.swift를 다시 쓰기 전에 전부 계산한다)
declare -a CHECKSUMS=()
for f in "${ALL_FRAMEWORKS[@]}"; do
  src="${RESULTS_DIR}/${f}.xcframework"
  [[ -d "${src}" ]] || { echo "✗ ${src} 없음 — 먼저 ./build.sh를 실행하세요" >&2; exit 1; }
  echo "▶︎ zip: ${f}"
  ditto -c -k --keepParent "${src}" "${DIST_DIR}/${f}.xcframework.zip"
  CHECKSUMS+=("$(swift package compute-checksum "${DIST_DIR}/${f}.xcframework.zip")")
done

# 2) Package.swift 생성
{
  cat <<EOF
// swift-tools-version: 5.9
//
// ⚠️ scripts/make-manifest.sh가 생성하는 파일 — 직접 수정하지 말 것.
// 바이너리는 GitHub Release(${VERSION}) 자산을 가리킨다.
import PackageDescription

let package = Package(
    name: "Lynx",
    platforms: [.iOS(.v12)],
    products: [
        // 바이너리 간 전이 링크가 자동으로 걸리지 않으므로 제품 하나로 전부 묶는다
        .library(
            name: "Lynx",
            targets: [
EOF
  for f in "${FRAMEWORKS[@]}"; do
    echo "                \"${f}\","
  done
  cat <<EOF
            ]
        )
EOF
  if [[ ${#EXTRA[@]} -gt 0 ]]; then
    cat <<EOF
        ,
        // devtool 플레이버 전용 — Lynx DevTool 데스크톱 연결에 필요한 프레임워크.
        // Lynx 제품과 함께 링크하고, 프로덕션 구성에서는 링크하지 않는다.
        .library(
            name: "LynxDevtool",
            targets: [
EOF
    for f in "${EXTRA[@]}"; do
      echo "                \"${f}\","
    done
    cat <<EOF
            ]
        )
EOF
  fi
  cat <<EOF
    ],
    targets: [
EOF
  for i in "${!ALL_FRAMEWORKS[@]}"; do
    f="${ALL_FRAMEWORKS[$i]}"
    cat <<EOF
        .binaryTarget(
            name: "${f}",
            url: "${BASE_URL}/${f}.xcframework.zip",
            checksum: "${CHECKSUMS[$i]}"
        ),
EOF
  done
  cat <<EOF
    ]
)
EOF
} > "${MANIFEST_OUT}"

# 3) 매니페스트 검증 — 루트가 아닌 곳에 썼으면 임시 패키지 디렉토리에서 검사한다
if [[ "${MANIFEST_OUT}" == "Package.swift" ]]; then
  swift package dump-package > /dev/null
else
  check_dir="$(mktemp -d)"
  cp "${MANIFEST_OUT}" "${check_dir}/Package.swift"
  (cd "${check_dir}" && swift package dump-package > /dev/null)
  rm -rf "${check_dir}"
fi
echo "✅ ${MANIFEST_OUT} 생성 완료 (${VERSION} → ${BASE_URL})"
