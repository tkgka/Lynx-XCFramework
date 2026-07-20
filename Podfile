platform :ios, '12.0'

target 'Lynx-XcFramework' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # 버전은 Lynx만 고정한다. 나머지 pod의 버전은 podspec 의존성 제약을
  # pod install이 해석해 결정하고 Podfile.lock에 기록된다.
  #   예) Lynx 3.6.0 → PrimJS/quickjs = 3.6.1 (정확 고정)
  #       Lynx 3.9.0 → PrimJS/quickjs = 3.8.0-alpha.6 (정확 고정)
  #       LynxService/Image → SDWebImage = 5.15.5, SDWebImageWebPCoder = 0.11.0
  pod 'Lynx', '4.0.0', :subspecs => [
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
  end
end
