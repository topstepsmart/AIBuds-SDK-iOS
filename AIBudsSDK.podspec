Pod::Spec.new do |s|
  # ==================== Basic Information ====================
  # SDK name and version
  s.name         = "AIBudsSDK"
  s.version      = "1.0.0-beta.4"
  s.summary      = "AIBuds SDK - Comprehensive AI-powered device development framework for iOS"
  s.description  = <<-DESC
                    AIBuds SDK is a powerful and comprehensive development framework designed to simplify the integration of AI-powered device functionalities into iOS applications. It provides modular components including core connectivity, Bluetooth management, audio processing, AI capabilities, logging utilities, and foundation services. The SDK supports seamless communication with AIBuds devices, enabling developers to build intelligent audio experiences with features like real-time audio streaming, voice recognition, and smart device management. With its flexible subspec architecture, developers can easily include only the components they need, from basic logging to full AI integration.
                   DESC
  
  # Metadata
  s.homepage     = "https://github.com/pcjbird/AIBudsSDK"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "pcjbird" => "pcjbird@hotmail.com" }
  s.platform     = :ios, "11.0"
  s.source       = { :git => "https://github.com/pcjbird/AIBudsSDK.git", :tag => s.version.to_s }
  
  # Default subspec - Core module will be installed by default
  s.default_subspec = 'Core'

  # Logging module - Provides logging capabilities
  s.subspec 'Log' do |log|
    log.subspec 'Core' do |logCore|
      logCore.vendored_frameworks = 'AIBudsSDK/AIBudsLog.xcframework'
      logCore.dependency 'zipzap'
      logCore.frameworks = 'Foundation'
    end

    # XLFacility subspec - Extended logging with browser support
    log.subspec 'XLFacility' do |xlfacility|
      xlfacility.vendored_frameworks = 'AIBudsSDK/AIBudsXLFacility.xcframework'
      xlfacility.dependency 'iOSLogBrowserSDK'
      xlfacility.dependency 'AIBudsSDK/Log/Core'
    end
  end

  # Foundation module - Base utilities, depends on Log
  s.subspec 'Foundation' do |foundation|
    foundation.vendored_frameworks = 'AIBudsSDK/AIBudsFoundation.xcframework'
    foundation.dependency 'AIBudsSDK/Log/Core'
    foundation.frameworks = 'Foundation', 'CoreGraphics'
  end

  # Core module - Main SDK functionality, depends on Foundation and Log
  s.subspec 'Core' do |core|
    core.vendored_frameworks = 'AIBudsSDK/AIBuds.xcframework'
    core.dependency 'AIBudsSDK/Log/Core'
    core.dependency 'AIBudsSDK/Foundation'
    core.frameworks = 'Foundation', 'CoreBluetooth', 'CoreGraphics'
  end

  # ABMate module - Device connectivity and management, required when the device uses the ABMate BLE protocol
  s.subspec 'ABMate' do |abmate|
    abmate.vendored_frameworks = 'AIBudsSDK/ABMate.xcframework'
    abmate.dependency 'AIBudsSDK/Core'
    abmate.dependency 'GCDWebServer'
    abmate.dependency 'libopus', '1.1'
  end

  # Third-party libraries collection
  s.subspec 'ThirdParty' do |thirdparty|
    # LAME - MP3 encoding library
    thirdparty.subspec 'Lame' do |lame|
      lame.vendored_frameworks = 'AIBudsSDK/LAME.xcframework'
    end
    
    # tenVad - Voice Activity Detection library
    thirdparty.subspec 'tenVad' do |ten_vad|
      ten_vad.vendored_frameworks = 'AIBudsSDK/ten_vad.framework'
    end
    
    # StarburstSdk - Starburst AI service SDK
    thirdparty.subspec 'StarburstSdk' do |starburstSdk|
      starburstSdk.vendored_frameworks = 'AIBudsSDK/StarburstSdk.framework'
      starburstSdk.dependency 'SocketRocket'
      starburstSdk.dependency 'AFNetworking', '~> 4.0'
    end
    
    # MagicHelper - Magic Cloud AI service SDK
    thirdparty.subspec 'MagicHelper' do |magicHelper|
      magicHelper.vendored_frameworks = 'AIBudsSDK/MagicHelper.framework', 'AIBudsSDK/MicrosoftCognitiveServicesSpeech.xcframework'
      magicHelper.vendored_libraries = 'AIBudsSDK/libQPlayAutoSDK.a'
      magicHelper.resource = 'AIBudsSDK/MGBundle.bundle'
      magicHelper.dependency 'SocketRocket'
      magicHelper.dependency 'onnxruntime-objc', '1.18.0'
      magicHelper.dependency 'AFNetworking', '~> 4.0'
    end
    
    # OpenSSL - Cryptography library
    thirdparty.subspec 'openssl' do |openssl|
      openssl.vendored_frameworks = 'AIBudsSDK/openssl.framework'
    end
    
    # MZEncryptSDK - On-device voice assistant service SDK, depends on OpenSSL
    thirdparty.subspec 'MZEncryptSDK' do |mzEncryptSDK|
      mzEncryptSDK.vendored_frameworks = 'AIBudsSDK/MZEncryptSDK.framework'
      mzEncryptSDK.dependency 'AIBudsSDK/ThirdParty/openssl'
    end
  end

  # Audio module - Audio processing capabilities
  s.subspec 'Audio' do |audio|
    audio.vendored_frameworks = 'AIBudsSDK/AIBudsAudio.xcframework'
    audio.dependency 'AIBudsSDK/Core'
    audio.dependency 'AIBudsSDK/ThirdParty/tenVad'
    audio.frameworks = 'Foundation', 'CoreAudio', 'CoreMedia', 'AVFoundation'
  end

  # AI module collection - Artificial intelligence features
  s.subspec 'AI' do |ai|
    # AI Foundation - Base AI utilities
    ai.subspec 'Foundation' do |ai_foundation|
      ai_foundation.vendored_frameworks = 'AIBudsSDK/AIBudsAIFoundation.xcframework'
      ai_foundation.dependency 'AIBudsSDK/Core'
    end

    # AI Core - Core AI functionality with database support
    ai.subspec 'Core' do |ai_core|
      ai_core.vendored_frameworks = 'AIBudsSDK/AIBudsAI.xcframework'
      ai_core.dependency 'AIBudsSDK/Core'
      ai_core.dependency 'AIBudsSDK/AI/Foundation'
      ai_core.dependency 'WCDB.swift', '2.1.16'
    end
    
    # StarBurst - Starburst AI integration
    ai.subspec 'StarBurst' do |starburst|
      starburst.vendored_frameworks = 'AIBudsSDK/AIBudsStarBurst.xcframework'
      starburst.dependency 'AIBudsSDK/Audio'
      starburst.dependency 'AIBudsSDK/ThirdParty/Lame'
      starburst.dependency 'AIBudsSDK/ThirdParty/StarburstSdk'
      starburst.dependency 'AIBudsSDK/AI/Core'
    end

    # MltCloud - Magic Cloud AI integration
    ai.subspec 'MltCloud' do |mltcloud|
      mltcloud.vendored_frameworks = 'AIBudsSDK/AIBudsMagicHelper.xcframework'
      mltcloud.dependency 'AIBudsSDK/Audio'
      mltcloud.dependency 'AIBudsSDK/ThirdParty/Lame'
      mltcloud.dependency 'AIBudsSDK/ThirdParty/MagicHelper'
      mltcloud.dependency 'AIBudsSDK/AI/Core'
      mltcloud.dependency 'libogg', '1.3.5'
    end

    # Dashboard - AI management dashboard
    ai.subspec 'Dashboard' do |dashboard|
      dashboard.dependency 'AIBudsSDK/AI/Core'
    end
  end

  # VoiceAssistant module - Voice assistant functionality
  s.subspec 'VoiceAssistant' do |voiceassistant|
    voiceassistant.vendored_frameworks = 'AIBudsSDK/AIBudsVoiceAssistant.xcframework'
    voiceassistant.dependency 'AIBudsSDK/Core'
    voiceassistant.dependency 'AIBudsSDK/ThirdParty/MZEncryptSDK'
  end

  # AllInOne module - Includes all features for convenience
  s.subspec 'AllInOne' do |allinone|
    allinone.dependency 'AIBudsSDK/Log'
    allinone.dependency 'AIBudsSDK/ABMate'
    allinone.dependency 'AIBudsSDK/AI'
    allinone.dependency 'AIBudsSDK/VoiceAssistant'
  end

end
