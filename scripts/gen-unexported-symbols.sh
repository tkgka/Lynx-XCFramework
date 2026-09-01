#!/bin/bash
#
# PrimJS / LynxBase의 unexported symbols 목록(symbols/<F>.unexported.txt)을 재생성한다.
#
# 목록 = 해당 프레임워크의 export 심볼 − 형제 프레임워크 7개가 참조(undefined)하는 심볼
#        − ObjC 심볼(_OBJC_* 등 — 소비 측 ObjC/Swift 링크를 건드리지 않기 위해 항상 유지)
#
# 목록에 있는 심볼은 링크 시 export 테이블에서 빠져 dead-strip/LTO가 제거할 수 있게 된다.
# 목록이 낡아 형제가 실제로 참조하는 심볼이 들어가면 아카이브의 링크 단계에서
# undefined symbol로 즉시 실패한다 — 런타임에 조용히 깨지는 경로가 아니다.
#
# 언제 돌리나: Lynx 버전 업 후 build.sh가 undefined symbol로 실패할 때. 절차(2-pass):
#   UNEXPORTED_LISTS=0 pod update          # 1차: 목록 없이 Pods 프로젝트 생성
#   PLATFORMS=device ./build.sh            # 1차 빌드 (아카이브만 있으면 됨)
#   scripts/gen-unexported-symbols.sh      # 목록 재생성 (기본 입력: build/ios_device.xcarchive)
#   pod update && ./build.sh               # 2차: 목록 적용해 전체 재빌드
#
# 사용법:
#   scripts/gen-unexported-symbols.sh [frameworks-dir]
#     frameworks-dir: <F>.framework/<F> 바이너리가 있는 디렉터리
#                     (기본: build/ios_device.xcarchive/Products/Library/Frameworks)
#
# Lynx 자체의 목록(symbols/Lynx.unexported.txt)은 와일드카드 한 줄(__Z*)의 정적 파일이라
# 이 스크립트가 건드리지 않는다.
#
set -euo pipefail
cd "$(dirname "$0")/.."

FRAMEWORKS_DIR="${1:-build/ios_device.xcarchive/Products/Library/Frameworks}"
OUT_DIR="symbols"
# build.sh의 FRAMEWORKS와 같은 8개 — 참조 집합(undefined 합집합) 계산에 전부 쓰인다.
ALL=(Lynx LynxBase LynxService LynxServiceAPI PrimJS SDWebImage SDWebImageWebPCoder libwebp)
# 목록을 생성할 대상. Lynx는 정적 __Z* 목록이라 제외한다.
TARGETS=(PrimJS LynxBase)

for f in "${ALL[@]}"; do
  bin="${FRAMEWORKS_DIR}/${f}.framework/${f}"
  if [[ ! -f "${bin}" ]]; then
    echo "✗ ${bin} 이 없습니다 — 먼저 device 아카이브를 빌드하세요 (PLATFORMS=device ./build.sh)" >&2
    exit 1
  fi
done

WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

for f in "${ALL[@]}"; do
  bin="${FRAMEWORKS_DIR}/${f}.framework/${f}"
  nm -gU "${bin}" | awk '{print $3}' | sort -u > "${WORK}/${f}.exports"
  nm -gu "${bin}" | sort -u > "${WORK}/${f}.undef"
done

lynx_version="$(sed -n "s/.*pod 'Lynx', '\([^']*\)'.*/\1/p" Podfile | head -1)"
mkdir -p "${OUT_DIR}"

for f in "${TARGETS[@]}"; do
  refs="${WORK}/${f}.refs"
  : > "${refs}"
  for o in "${ALL[@]}"; do
    [[ "${o}" == "${f}" ]] && continue
    cat "${WORK}/${o}.undef" >> "${refs}"
  done
  sort -u -o "${refs}" "${refs}"

  out="${OUT_DIR}/${f}.unexported.txt"
  {
    echo "# ${f} unexported symbols — Lynx ${lynx_version:-?} (scripts/gen-unexported-symbols.sh 산출물)"
    echo "# 형제 프레임워크 7개의 undefined 심볼에 잡히지 않는 export만 담는다."
    echo "# ObjC 심볼(_OBJC_*, \$ 포함)은 제외 — 소비 측 ObjC/Swift 링크를 건드리지 않는다."
    echo "# 버전 업 후 링크가 undefined symbol로 깨지면 목록이 낡은 것 — 재생성 절차는 스크립트 헤더 참고."
    comm -23 "${WORK}/${f}.exports" "${refs}" | grep -vE 'OBJC|\$|^__mh|^\.objc'
  } > "${out}"

  total="$(wc -l < "${WORK}/${f}.exports" | tr -d ' ')"
  kept="$(comm -12 "${WORK}/${f}.exports" "${refs}" | wc -l | tr -d ' ')"
  listed="$(grep -cv '^#' "${out}")"
  echo "▶︎ ${out}: export ${total}개 중 참조 ${kept}개 유지, ${listed}개 unexport"
done
