Pod::Spec.new do |s|
  s.name             = 'aibuds_live_stream_flutter'
  s.version          = '0.1.0'
  s.summary          = 'Flutter wrapper for AIBudsLiveStream middleware.'
  s.description      = 'Flutter plugin that registers the native AIBudsLiveStreamFlutterPlugin xcframework and exposes player and streamer APIs.'
  s.homepage         = 'https://github.com/topstepsmart/AIBuds-SDK-iOS/aibuds-live-stream-flutter'
  s.license          = { :type => 'Commercial', :file => '../LICENSE' }
  s.author           = { 'pcjbird' => 'pcjbird@hotmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.vendored_frameworks = [
    'Frameworks/AIBudsLiveStreamFlutterPlugin.xcframework'
  ]
  s.dependency 'Flutter'
  s.dependency 'AIBudsSDK/LiveStream'
  
  s.platform = :ios, '13.0'
  s.swift_version = '5.9'
  s.static_framework = true
end
