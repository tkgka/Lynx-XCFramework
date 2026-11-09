source 'https://cdn.cocoapods.org/'
source 'https://github.com/lynx-family/Specs.git'

platform :ios, '12.0'

# devtool 빌드 스위치 — devtool/Podfile이 이 파일을 평가하기 전에 1로 둔다
# (scripts/build-devtool.sh). 1이면 LynxDevtool · BaseDevtool · DebugRouter와
# LynxService의 Devtool 서브스펙을 더하고, 아래 post_install의 심볼 축소를 끈다.
# 릴리스(Build & Release) 빌드는 이 값을 건드리지 않는다 — 기본 0.
LYNX_DEVTOOL = ENV.fetch('LYNX_DEVTOOL', '0') == '1'

# Lynx 버전의 단일 소스는 아래 `pod 'Lynx', '<버전>'` 줄이다 — scripts/set-lynx-version.sh와
# 워크플로가 그 줄을 sed로 읽고 쓴다. devtool pod은 Lynx와 같은 버전이어야 하므로
# (lynxjs.org "Integrating Lynx DevTool") 같은 줄에서 읽어 맞춘다.
LYNX_VERSION = File.read(__FILE__)[/^ *pod 'Lynx', '([0-9.]+)'/, 1] \
  or raise "Podfile에서 `pod 'Lynx', '<버전>'` 줄을 찾지 못했습니다"

# DebugRouter는 Lynx와 독립적으로 버전이 매겨진다(LynxDevtool 4.2.0 podspec은 >= 5.0.15).
# lynxjs.org 통합 문서가 고정하는 값을 기본으로 두고, 필요하면 환경변수로 올린다.
DEBUG_ROUTER_VERSION = ENV.fetch('DEBUG_ROUTER_VERSION', '5.0.15')

target 'Lynx-XcFramework' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # 버전은 Lynx만 고정한다. 나머지 pod의 버전은 podspec 의존성 제약을
  # pod install이 해석해 결정하고 Podfile.lock에 기록된다.
  #   예) Lynx 3.6.0 → PrimJS/quickjs = 3.6.1 (정확 고정)
  #       Lynx 3.9.0 → PrimJS/quickjs = 3.8.0-alpha.6 (정확 고정)
  #       LynxService/Image → SDWebImage = 5.15.5, SDWebImageWebPCoder = 0.11.0
  pod 'Lynx', '4.2.0', :subspecs => [
    'Framework',
  ]
  pod 'PrimJS', :subspecs => ['quickjs', 'napi']

  pod 'LynxService', :subspecs => [
      'Image',
      'Http',
      # Devtool 서브스펙이 LynxEnv의 devtool 서비스 seam(LynxServiceDevToolProtocol)을 채운다.
      *(LYNX_DEVTOOL ? ['Devtool'] : []),
  ]

  # ImageService dependencies:
  pod 'SDWebImage'
  pod 'SDWebImageWebPCoder'

  if LYNX_DEVTOOL
    # Lynx DevTool 데스크톱(lynx-family/lynx-devtool)과 연결되는 앱 쪽 구성 요소.
    # LynxDevtool/Framework가 BaseDevtool · DebugRouter · PrimJS의 quickjs_debugger/
    # profiler · SocketRocket을 끌어오고, 리소스 번들 LynxDebugResources(LogBox, 스위치
    # 페이지, lynx_core_dev.js)를 프레임워크 안에 싣는다. LynxRecorder 서브스펙은 Lynx -dev
    # 배포판과 짝이라 여기서는 넣지 않는다.
    pod 'LynxDevtool', LYNX_VERSION, :subspecs => ['Framework']
    pod 'BaseDevtool', LYNX_VERSION
    pod 'DebugRouter', DEBUG_ROUTER_VERSION
    pod 'DebugRouter/MessageTransceiverEnable', DEBUG_ROUTER_VERSION
  end

end

# 심볼 가시성 축소 스위치. 0이면 아래 post_install의 hidden 처리를 통째로 건너뛴다
#   HIDE_SYMBOLS=0 pod update
# devtool 빌드에서는 값과 무관하게 끈다 — LynxDevtool이 Lynx 엔진의 C++ 심볼
# (LYNX_EXPORT_FOR_DEVTOOL 116곳과 inspector 훅)을 프레임워크 경계 너머로 참조하므로
# hidden으로 내리면 LynxDevtool 링크가 깨진다.
HIDE_SYMBOLS = !LYNX_DEVTOOL && ENV.fetch('HIDE_SYMBOLS', '1') == '1'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
    # pod 소스별 -Werror 제거: 새 Xcode의 clang이 경고를 추가할 때마다
    # 빌드가 깨지는 것을 막는다 (예: Xcode 26.5의 -Wnontrivial-memcall이
    # Lynx vector.h의 non-trivially-copyable memmove에 걸려 에러 승격).
    target.source_build_phase.files.each do |file|
      flags = file.settings && file.settings['COMPILER_FLAGS']
      next unless flags && flags.include?('-Werror')
      file.settings['COMPILER_FLAGS'] = flags.gsub(/-Werror(=\S+)?/, '').squeeze(' ').strip
    end

    # Lynx 엔진의 C/C++ 심볼을 hidden으로 내린다.
    #
    # Lynx 소스(core/base/lynx_export.h)는 "-fvisibility=hidden 때문에 심볼이 기본적으로
    # export되지 않는다"를 전제로 공개 API에만 LYNX_EXPORT를 붙여 두었는데, podspec에는
    # 그 설정이 없어서 엔진 내부 심볼까지 전부 노출된다 — 4.0.1 arm64 기준 export 심볼
    # 11,580개 중 10,171개가 C++ 맹글 심볼인 반면 LYNX_EXPORT 주석은 80개뿐이다.
    # 그 결과 __LINKEDIT이 1.84MB로 부풀고, build.sh의 DEAD_CODE_STRIPPING/thin LTO도
    # 전부 export된 심볼을 루트로 잡아 아무것도 제거하지 못한다.
    #
    # .m/.mm은 반드시 제외한다. ObjC 클래스 심볼(_OBJC_CLASS_$_)도 같이 hidden 되는데,
    # 소비 측이 참조하는 클래스 중 8개(LynxUI, LynxPropsProcessor, LynxCustomMeasureShadowNode,
    # LynxNativeLayoutNode, AlignParam, MeasureParam, LynxColorUtils, DevToolOverlayDelegate)가
    # .mm에 있어 링크가 깨진다.
    #
    # Lynx 타깃에만 적용한다. Lynx가 LynxBase/PrimJS의 C++ 심볼 375개(lynx::base::logging::*,
    # Napi::* 등)를 프레임워크 경계 너머로 가져다 쓰므로 그쪽을 hidden으로 내리면 링크가 깨진다.
    # 반대 방향(Lynx의 C++ 심볼을 밖에서 참조)은 LynxService/LynxServiceAPI/소비 측 모두
    # 0건임을 nm으로 확인했다.
    next unless HIDE_SYMBOLS && target.name == 'Lynx'
    target.source_build_phase.files.each do |file|
      path = file.file_ref&.path.to_s
      next unless path.end_with?('.cc', '.cpp', '.c')
      settings = file.settings || {}
      flags = settings['COMPILER_FLAGS'].to_s
      next if flags.include?('-fvisibility=hidden')
      settings['COMPILER_FLAGS'] = "#{flags} -fvisibility=hidden".strip
      file.settings = settings
    end

    # devtool 전용 export(LYNX_EXPORT_FOR_DEVTOOL, 116곳)를 끈다. 릴리스 빌드에서는
    # LynxDevtool pod이 배포 대상이 아니라 이 심볼들을 참조하는 쪽이 아예 없다. podspec이
    # xcconfig에 박아 넣는 값이라 생성된 xcconfig를 직접 고친다. devtool 빌드는 바로 그
    # 참조자를 링크하므로 그대로 둔다.
    next if LYNX_DEVTOOL
    target.build_configurations.each do |config|
      xcconfig_path = config.base_configuration_reference&.real_path
      next unless xcconfig_path && File.exist?(xcconfig_path)
      text = File.read(xcconfig_path)
      patched = text.gsub('EXPORT_SYMBOLS_FOR_DEVTOOL=1', 'EXPORT_SYMBOLS_FOR_DEVTOOL=0')
      File.write(xcconfig_path, patched) unless patched == text
    end
  end
end
