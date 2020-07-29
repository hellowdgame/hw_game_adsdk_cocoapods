#
#  Be sure to run `pod spec lint HWAdsSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "hw_game_adsdk_cocoapods"
  spec.version      = "0.0.4"
  spec.summary      = "用于请求HW广告,一键集成SDK"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = "HWAdsSDK是哈乐沃德对外提供广告SDK，通过该sdk可请求mopub、谷歌、FaceBook、广点通、穿山甲、Sigmob、Applovin、UnityAds、IronSource、Mintegral、Vungle共11家广告商的广告。"

  spec.homepage     = "https://github.com/hellowdgame/hw_game_adsdk_cocoapods"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See https://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  spec.license      = { :type => "MIT", :file => "LICENSE" }  #开源协议
  # spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  spec.author             = { "HLY" => "hly091516@163.com" }
  # Or just: spec.author    = "HLY"
  # spec.authors            = { "HLY" => "hly091516@163.com" }
  # spec.social_media_url   = "https://twitter.com/HLY"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # spec.platform     = :ios
   spec.platform     = :ios, "9.0"

  #  When using multiple platforms
  # spec.ios.deployment_target = "5.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  spec.source       = { :git => "https://github.com/hellowdgame/hw_game_adsdk_cocoapods.git", :tag => "#{spec.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #
    
    #spec.source_files = 'SDK/**/*.{h,m}' 该路径下所有
    
    spec.source_files = 'Adapter/**/*.{h,m}'
    

  # spec.public_header_files = "Classes/**/*.h"

    #spec.subspec 'Adapter' do |ss|
     #   ss.subspec 'Adjust' do |ss1|
      #  ss1.source_files = 'Adapter/Adjust/**/*.{h,m}'
       # end
        #ss.subspec 'mopubiOSSdk' do |ss7|
        #ss7.vendored_frameworks  = 'SDK/HwFrameworkUpTest1.framework'
        #ss7.source_files = 'Adapter/mopub-ios-sdk/MoPubSDK/**/*.{h,m}'
        #ss7.resources = "Adapter/mopub-ios-sdk/MoPubSDK/Resources/*.png"
        #ss7.vendored_libraries = "Adapter/mopub-ios-sdk/MoPubSDK/Viewability/Avid/libAvid-mopub-3.6.1.a"
        #ss7.vendored_frameworks  = 'Adapter/mopub-ios-sdk/MoPubSDK/Viewability/MOAT/MPUBMoatMobileAppKit.framework','SDK/HwFrameworkUpTest1.framework','SDK/AppsFlyerFramework/AppsFlyerLib.framework'
        #end
        #ss.subspec 'AdMobAdapters' do |ss2|
        #ss2.vendored_frameworks  = 'SDK/HwFrameworkUpTest1.framework','SDK/AppsFlyerFramework/AppsFlyerLib.framework'
        #ss2.dependency 'HWAdsSDK/Adapter/mopubiOSSdk'
        #ss2.source_files = 'Adapter/MoPub-AdMob-Adapters/**/*.{h,m}'
        #end
        #ss.subspec 'ApplovinAdapters' do |ss3|
        #ss3.vendored_frameworks  = 'SDK/HwFrameworkUpTest1.framework','SDK/AppsFlyerFramework/AppsFlyerLib.framework'
        #ss3.dependency 'HWAdsSDK/Adapter/mopubiOSSdk'
        #ss3.source_files = 'Adapter/MoPub-Applovin-Adapters/**/*.{h,m}'
        #end
        #ss.subspec 'CSJAdapters' do |ss4|
        #ss4.vendored_frameworks  = 'SDK/HwFrameworkUpTest1.framework','SDK/AppsFlyerFramework/AppsFlyerLib.framework'
        #ss4.dependency 'HWAdsSDK/Adapter/mopubiOSSdk'
        #ss4.source_files = 'Adapter/Mopub-CSJ-Adapters/**/*.{h,m}'
        #end
        #ss.subspec 'FacebookAdapters' do |ss5|
        ##ss5.vendored_frameworks  = 'SDK/HwFrameworkUpTest1.framework','SDK/AppsFlyerFramework/AppsFlyerLib.framework'
        #ss5.dependency 'HWAdsSDK/Adapter/mopubiOSSdk'
        #ss5.vendored_frameworks  = 'SDK/FBSDKCoreKit.framework','SDK/FBAudienceNetwork.framework','SDK/HwFrameworkUpTest1.framework'
        #ss5.source_files = 'Adapter/MoPub-FacebookAudienceNetwork-Adapters/**/*.{h,m}'
        #end
        #ss.subspec 'GDTAdapters' do |ss6|
        #ss6.vendored_frameworks  = 'SDK/HwFrameworkUpTest1.framework','SDK/AppsFlyerFramework/AppsFlyerLib.framework'
        #ss6.dependency 'HWAdsSDK/Adapter/mopubiOSSdk'
        #ss6.source_files = 'Adapter/Mopub-GDT-Adapters/**/*.{h,m}'
        #end
        
        #ss.subspec 'IronSourceAdapters' do |ss8|
        #ss8.vendored_frameworks  = 'SDK/HwFrameworkUpTest1.framework','SDK/AppsFlyerFramework/AppsFlyerLib.framework'
        #ss8.dependency 'HWAdsSDK/Adapter/mopubiOSSdk'
        #ss8.source_files = 'Adapter/MoPub-IronSource-Adapters/**/*.{h,m}'
        #end
        #ss.subspec 'MintegralAdapters' do |ss9|
        #ss9.vendored_frameworks  = 'SDK/HwFrameworkUpTest1.framework','SDK/AppsFlyerFramework/AppsFlyerLib.framework'
        #ss9.dependency 'HWAdsSDK/Adapter/mopubiOSSdk'
        #ss9.source_files = 'Adapter/MoPub-Mintegral-Adapters/**/*.{h,m}'
        #end
        #ss.subspec 'SigmobAdapters' do |ss10|
        #ss10.vendored_frameworks  = 'SDK/HwFrameworkUpTest1.framework','SDK/AppsFlyerFramework/AppsFlyerLib.framework'
        #ss10.dependency 'HWAdsSDK/Adapter/mopubiOSSdk'
        #ss10.source_files = 'Adapter/Mopub-Sigmob-Adapters/**/*.{h,m}'
        #end
        #ss.subspec 'UnityAdsAdapters' do |ss11|
        #ss11.vendored_frameworks  = 'SDK/HwFrameworkUpTest1.framework','SDK/AppsFlyerFramework/AppsFlyerLib.framework'
        #ss11.dependency 'HWAdsSDK/Adapter/mopubiOSSdk'
        #ss11.source_files = 'Adapter/MoPub-UnityAds-Adapters/**/*.{h,m}'
        #end
        #ss.subspec 'VungleAdapters' do |ss12|
        #ss12.vendored_frameworks  = 'SDK/HwFrameworkUpTest1.framework','SDK/AppsFlyerFramework/AppsFlyerLib.framework'
        #ss12.dependency 'HWAdsSDK/Adapter/mopubiOSSdk'
        #ss12.source_files = 'Adapter/MoPub-Vungle-Adapters/**/*.{h,m}'
        #end
    #end


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # spec.resource  = "icon.png"
    spec.resources = "Adapter/mopub-ios-sdk/MoPubSDK/Resources/*.png"

  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #
    #非系统框架
    #spec.vendored_frameworks  = 'SDK/AppsFlyerFramework/AppsFlyerLib.framework','SDK/HwFrameworkUpTest1.framework','SDK/FBSDKCoreKit.framework','SDK/FBAudienceNetwork.framework','Adapter/mopub-ios-sdk/MoPubSDK/Viewability/MOAT/MPUBMoatMobileAppKit.framework'
    #,'SDK/FBAudienceNetwork.framework'
    spec.vendored_frameworks = "SDK/**/*.framework"
    # 系统框架
    spec.frameworks = "AdSupport","AVFoundation","CoreGraphics","CoreLocation","CoreMedia","CoreTelephony","Foundation","MediaPlayer","MessageUI","QuartzCore","SafariServices","StoreKit","SystemConfiguration","UIKit","WebKit"
    #非系统静态库
   spec.vendored_libraries = "Adapter/mopub-ios-sdk/MoPubSDK/Viewability/Avid/libAvid-mopub-3.6.1.a"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.
    spec.user_target_xcconfig = {
    'ENABLE_BITCODE' => 'NO'
    }
   
      spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
   #spec.dependency "JSONKit", "~> 1.4"
  spec.dependency "Google-Mobile-Ads-SDK", "7.59.0"
  spec.dependency "AppLovinSDK", "6.12.6"
  spec.dependency "IronSourceSDK", "6.16.1.0"
  spec.dependency "UnityAds", "3.4.2"
  spec.dependency "VungleSDK-iOS", "6.5.3"
  spec.dependency "Bytedance-UnionAD", "3.0.0.2"
  #, "~> 1.9.8.2"
  spec.dependency "GDTMobSDK", "~> 4.11.8"
  spec.dependency "SigmobAd-iOS", "2.18.2"
  spec.dependency "MintegralAdSDK/BannerAd", "6.2.0.0"
  spec.dependency "MintegralAdSDK/BidBannerAd", "6.2.0.0"
  spec.dependency "MintegralAdSDK/BidInterstitialVideoAd", "6.2.0.0"
  spec.dependency "MintegralAdSDK/BidNativeAd", "6.2.0.0"
  spec.dependency "MintegralAdSDK/BidRewardVideoAd", "6.2.0.0"
  spec.dependency "MintegralAdSDK/InterstitialVideoAd", "6.2.0.0"
  spec.dependency "MintegralAdSDK/NativeAd", "6.2.0.0"
  spec.dependency "MintegralAdSDK/RewardVideoAd", "6.2.0.0"
    
end
