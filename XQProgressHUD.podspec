#
# Be sure to run `pod lib lint XQProgressHUD.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XQProgressHUD'
  s.version          = '0.0.1'
  s.summary          = 'Rotating animation view'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Rotating animation for network requests.
                       DESC

  s.homepage         = 'https://github.com/XinQianLiu/XQProgressHUD'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = 'MIT'
  s.author           = { 'LiuXinQian' => '1613565807@qq.com' }
  s.source           = { :git => 'https://github.com/XinQianLiu/XQProgressHUD.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'

  s.source_files = 'XQProgressHUD/Classes/**/*'
  
  s.resource_bundles = {
     'XQProgressHUD' => ['XQProgressHUD/Assets/.gif']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'ImageIO','Foundation'
  # s.dependency 'AFNetworking', '~> 2.3'
end
