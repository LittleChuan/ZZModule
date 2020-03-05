#
# Be sure to run `pod lib lint ZZModule.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZZModule'
  s.version          = '0.1.0'
  s.summary          = 'Modularization develop tool for Swift'
  s.description      = 'Call any viewController/view without know its Class. Use Scheme to Jump pages'

  s.homepage         = 'https://github.com/LittleChuan/ZZModule'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ZackXXC' => 'zack@littlelights.ai' }
  s.source           = { :git => 'https://github.com/LittleChuan/ZZModule.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.swift_version = '4.0', '5.0'

  s.source_files = 'ZZModule/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ZZModule' => ['ZZModule/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
