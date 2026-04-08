Pod::Spec.new do |s|
  s.name         = "AIBudsSDK"
  s.version      = "1.0.0-beta.1"
  s.summary      = "AIBuds SDK - Comprehensive AI-powered device development framework for iOS"
  s.description  = <<-DESC
                    AIBuds SDK is a powerful and comprehensive development framework designed to simplify the integration of AI-powered device functionalities into iOS applications. It provides modular components including core connectivity, Bluetooth management, audio processing, AI capabilities, logging utilities, and foundation services. The SDK supports seamless communication with AIBuds devices, enabling developers to build intelligent audio experiences with features like real-time audio streaming, voice recognition, and smart device management. With its flexible subspec architecture, developers can easily include only the components they need, from basic logging to full AI integration.
                   DESC
  s.homepage     = "https://github.com/pcjbird/AIBudsSDK"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "pcjbird" => "pcjbird@hotmail.com" }
  s.platform     = :ios, "11.0"
  s.source       = { :git => "https://github.com/pcjbird/AIBudsSDK.git", :tag => s.version.to_s }
  
  
  s.default_subspec = 'Core'

  s.subspec 'Log' do |log|
    log.vendored_frameworks = 'AIBudsSDK/AIBudsLog.xcframework'

    log.subspec 'XLFacility' do |xlfacility|
      xlfacility.vendored_frameworks = 'AIBudsSDK/AIBudsXLFacility.xcframework'
      xlfacility.dependency 'iOSLogBrowserSDK'
    end
  end

  s.subspec 'Foundation' do |foundation|
    foundation.vendored_frameworks = 'AIBudsSDK/AIBudsFoundation.xcframework'
    foundation.dependency 'AIBudsSDK/Log'
  end

  s.subspec 'Core' do |core|
    core.vendored_frameworks = 'AIBudsSDK/AIBuds.xcframework'
    core.dependency 'AIBudsSDK/Log'
    core.dependency 'AIBudsSDK/Foundation'
  end

  s.subspec 'ABMate' do |abmate|
    abmate.vendored_frameworks = 'AIBudsSDK/ABMate.xcframework'
    abmate.dependency 'AIBudsSDK/Core'
    abmate.dependency 'GCDWebServer'
    abmate.dependency 'libopus', '1.1'
  end

  s.subspec 'ThirdParty' do |thirdparty|
    thirdparty.subspec 'Lame' do |lame|
      lame.vendored_frameworks = 'AIBudsSDK/LAME.xcframework'
    end
    thirdparty.subspec 'tenVad' do |ten_vad|
      ten_vad.vendored_frameworks = 'AIBudsSDK/ten_vad.framework'
    end
    thirdparty.subspec 'StarburstSdk' do |starburstSdk|
      starburstSdk.vendored_frameworks = 'AIBudsSDK/StarburstSdk.framework'
      starburstSdk.dependency 'SocketRocket'
      starburstSdk.dependency 'AFNetworking', '~> 4.0'
    end
    thirdparty.subspec 'MagicHelper' do |magicHelper|
      magicHelper.vendored_frameworks = 'AIBudsSDK/MagicHelper.framework', 'AIBudsSDK/MicrosoftCognitiveServicesSpeech.xcframework'
      magicHelper.vendored_libraries = 'AIBudsSDK/libQPlayAutoSDK.a'
      magicHelper.resource = 'AIBudsSDK/MGBundle.bundle'
      magicHelper.dependency 'SocketRocket'
      magicHelper.dependency 'onnxruntime-objc', '1.18.0'
      magicHelper.dependency 'AFNetworking', '~> 4.0'
    end
    thirdparty.subspec 'openssl' do |openssl|
      openssl.vendored_frameworks = 'AIBudsSDK/openssl.framework'
    end
    thirdparty.subspec 'MZEncryptSDK' do |mzEncryptSDK|
      mzEncryptSDK.vendored_frameworks = 'AIBudsSDK/MZEncryptSDK.framework'
      mzEncryptSDK.dependency 'AIBudsSDK/ThirdParty/openssl'
    end
  end

  s.subspec 'Audio' do |audio|
    audio.vendored_frameworks = 'AIBudsSDK/AIBudsAudio.xcframework'
    audio.dependency 'AIBudsSDK/Core'
    audio.dependency 'AIBudsSDK/ThirdParty/tenVad'
  end

  s.subspec 'AI' do |ai|

    ai.subspec 'Foundation' do |ai_foundation|
      ai_foundation.vendored_frameworks = 'AIBudsSDK/AIBudsAIFoundation.xcframework'
      ai_foundation.dependency 'AIBudsSDK/Core'
    end

    ai.subspec 'Core' do |ai_core|
      ai_core.vendored_frameworks = 'AIBudsSDK/AIBudsAI.xcframework'
      ai_core.dependency 'AIBudsSDK/Core'
      ai_core.dependency 'AIBudsSDK/AI/Foundation'
      ai_core.dependency 'WCDB.swift', '2.1.15'
    end
    
    ai.subspec 'Starburst' do |starburst|
      starburst.vendored_frameworks = 'AIBudsSDK/AIBudsStarBurst.xcframework'
      starburst.dependency 'AIBudsSDK/Audio'
      starburst.dependency 'AIBudsSDK/ThirdParty/Lame'
      starburst.dependency 'AIBudsSDK/ThirdParty/StarburstSdk'
      starburst.dependency 'AIBudsSDK/AI/Core'
    end

    ai.subspec 'MltCloud' do |mltcloud|
      mltcloud.vendored_frameworks = 'AIBudsSDK/AIBudsMagicHelper.xcframework'
      mltcloud.dependency 'AIBudsSDK/Audio'
      mltcloud.dependency 'AIBudsSDK/ThirdParty/Lame'
      mltcloud.dependency 'AIBudsSDK/ThirdParty/MagicHelper'
      mltcloud.dependency 'AIBudsSDK/AI/Core'
    end

    ai.subspec 'Dashboard' do |dashboard|
      dashboard.dependency 'AIBudsSDK/AI/Core'
    end
  end

  s.subspec 'VoiceAssistant' do |voiceassistant|
    voiceassistant.vendored_frameworks = 'AIBudsSDK/AIBudsVoiceAssistant.xcframework'
    voiceassistant.dependency 'AIBudsSDK/Core'
    voiceassistant.dependency 'AIBudsSDK/ThirdParty/MZEncryptSDK'
  end

  s.subspec 'AllInOne' do |allinone|
    allinone.dependency 'AIBudsSDK/ABMate'
    allinone.dependency 'AIBudsSDK/AI'
    allinone.dependency 'AIBudsSDK/VoiceAssistant'
  end

end
