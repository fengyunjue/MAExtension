#
# Be sure to run `pod lib lint MAExtension.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'MAExtension'
    s.version          = '0.1.12'
    s.summary          = 'A short description of MAExtension.'

    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!

    s.description      = <<-DESC
    TODO: Add long description of the pod here.
                       DESC

    s.homepage         = 'https://github.com/fengyunjue/MAExtension'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'ma772528138@qq.com' => 'ma772528138@qq.com' }
    s.source           = { :git => '.', :tag => s.version.to_s }
    #s.source           = { :git => 'https://github.com/fengyunjue/MAExtension.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

    s.ios.deployment_target = '9.0'
    
    s.pod_target_xcconfig = {
        'SWIFT_VERSION' => '4.1'
    }
    
    # s.frameworks = 'UIKit', 'MapKit'
    
    s.subspec 'Base' do |base|
        base.source_files = 'MAExtension/{Base,Foundation,UIKit}/*'
    end
    
    s.subspec 'NSLogger' do |logger|
        logger.source_files = 'MAExtension/NSLogger/*'
        logger.dependency 'NSLogger/Swift'
    end
    
    s.subspec 'JSON' do |json|
        json.source_files = 'MAExtension/JSON/*'
        json.dependency 'SwiftyJSON'
    end
end
