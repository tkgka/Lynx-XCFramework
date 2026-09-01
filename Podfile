platform :ios, '12.0'

target 'Lynx-XcFramework' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # 버전은 Lynx만 고정한다. 나머지 pod의 버전은 podspec 의존성 제약을
  # pod install이 해석해 결정하고 Podfile.lock에 기록된다.
  #   예) Lynx 3.6.0 → PrimJS/quickjs = 3.6.1 (정확 고정)
  #       Lynx 3.9.0 → PrimJS/quickjs = 3.8.0-alpha.6 (정확 고정)
  #       LynxService/Image → SDWebImage = 5.15.5, SDWebImageWebPCoder = 0.11.0
  pod 'Lynx', '4.0.1', :subspecs => [
    'Framework',
  ]
  pod 'PrimJS', :subspecs => ['quickjs', 'napi']

  pod 'LynxService', :subspecs => [
      'Image',
      'Http',
  ]

  # ImageService dependencies:
  pod 'SDWebImage'
  pod 'SDWebImageWebPCoder'

end

# 심볼 가시성 축소 스위치. 0이면 아래 post_install의 hidden 처리를 통째로 건너뛴다
#   HIDE_SYMBOLS=0 pod update
HIDE_SYMBOLS = ENV.fetch('HIDE_SYMBOLS', '1') == '1'

# unexported symbols 목록 스위치. symbols/<타깃>.unexported.txt 가 있는 타깃(Lynx/PrimJS/
# LynxBase)의 링크에 -unexported_symbols_list 를 건다. export에서 빠진 심볼은 dead-strip과
# LTO의 루트에서 제외되어 미사용 코드가 실제로 제거된다. 형제가 참조하는 심볼은 목록
# 생성 시점에 nm 교차 분석으로 걸러져 있다 (scripts/gen-unexported-symbols.sh).
# 목록이 낡으면 아카이브의 링크 단계에서 undefined symbol로 즉시 실패한다 — 그때는
# 스크립트 헤더의 2-pass 절차로 재생성한다. 0이면 통째로 건너뛴다:
#   UNEXPORTED_LISTS=0 pod update
UNEXPORTED_LISTS = ENV.fetch('UNEXPORTED_LISTS', '1') == '1'
UNEXPORTED_DIR = File.expand_path('symbols', __dir__)

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

    # unexported symbols 목록을 링커에 건다 (위 UNEXPORTED_LISTS 주석 참고).
    # 목록 파일이 있는 타깃(Lynx/PrimJS/LynxBase)에만 적용된다.
    if UNEXPORTED_LISTS
      list_path = File.join(UNEXPORTED_DIR, "#{target.name}.unexported.txt")
      if File.exist?(list_path)
        target.build_configurations.each do |config|
          config.build_settings['OTHER_LDFLAGS'] = [
            '$(inherited)',
            "-Wl,-unexported_symbols_list,#{list_path}",
          ]
        end
      end
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

    # devtool 전용 export(LYNX_EXPORT_FOR_DEVTOOL, 116곳)를 끈다. LynxDevtool pod은
    # 배포 대상이 아니라 이 심볼들을 참조하는 쪽이 아예 없다. podspec이 xcconfig에
    # 박아 넣는 값이라 생성된 xcconfig를 직접 고친다.
    target.build_configurations.each do |config|
      xcconfig_path = config.base_configuration_reference&.real_path
      next unless xcconfig_path && File.exist?(xcconfig_path)
      text = File.read(xcconfig_path)
      patched = text.gsub('EXPORT_SYMBOLS_FOR_DEVTOOL=1', 'EXPORT_SYMBOLS_FOR_DEVTOOL=0')
      File.write(xcconfig_path, patched) unless patched == text
    end
  end
end
