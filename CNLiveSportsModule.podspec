#
# Be sure to run `pod lib lint CNLiveSportsModule.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'CNLiveSportsModule'
    s.version          = '0.0.1'
    s.summary          = '大众体育.'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    大众体育.
    DESC
    
    s.homepage         = 'http://bj.gitlab.cnlive.com/ios-team/CNLiveSportsModule.git'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { '郭瑞朋' => 'guoruipeng@cnlive.com' }
    s.source           = { :git => 'http://bj.gitlab.cnlive.com/ios-team/CNLiveSportsModule.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.ios.deployment_target = '9.0'
    # s.resource_bundles = {
    #   'CNLiveSportsModule' => ['CNLiveSportsModule/Assets/*.png']
    # }
    
    # s.public_header_files = 'Pod/Classes/**/*.h'
    
    s.subspec 'Manage' do |ss|
        ss.source_files = 'CNLiveSportsModule/Classes/Manage/*.{h,m}'
    end
    
    s.subspec 'Module' do |ss|
        ss.source_files = 'CNLiveSportsModule/Classes/Module/*.{h,m}'
        ss.dependency 'CNLiveSportsModule/Controller'
    end
    #############################################################################
    ##################################Controller#####################################
    s.subspec 'Controller' do |ss|
        ss.source_files = 'CNLiveSportsModule/Classes/Controller/*'
        ss.dependency 'CNLiveSportsModule/View'
        ss.dependency 'CNLiveSportsModule/Manage'
    end
    #############################################################################
    ##################################View###########################################
    s.subspec 'View' do |ss|
        ss.source_files = 'CNLiveSportsModule/Classes/View/*.{h,m}'
        #        ss.dependency 'CNLiveSportsModule/Model'
    end
    #############################################################################
    ##################################Model###########################################
    s.subspec 'Model' do |ss|
        ss.source_files = 'CNLiveSportsModule/Classes/Model/*.{h,m}'
    end
    s.static_framework = true
    s.vendored_frameworks = 'CNLiveSportsModule/Classes/FrameWork/BaiduTraceSDK.framework'
    
    s.frameworks = 'UIKit', 'MapKit'
    s.dependency 'CNLiveTripartiteManagement/BaiduMapKit'#百度地图SDK
    s.dependency 'CNLiveTripartiteManagement/BMKLocationKit'#定位
    s.dependency 'CNLiveTripartiteManagement/QMUIKit'
    s.dependency 'CNLiveTripartiteManagement/SDWebImage'
    s.dependency 'CNLiveTripartiteManagement/Masonry'
    s.dependency 'CNLiveTripartiteManagement/MJRefresh'
    s.dependency 'CNLiveBaseKit'
    s.dependency 'CNLiveRequestBastKit'
    s.dependency 'CNLiveCommonClass'
    s.dependency 'CNLiveEnvironment'
    s.dependency 'CNLiveCustomUI'
    # 服务层
    s.dependency 'CNLiveServices'
    s.dependency 'CNLiveManager'
end
