#
# Be sure to run `pod lib lint Sensorberg.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Sensorberg"
  s.version          = "0.1.0"
  s.summary          = "A short description of Sensorberg."
  s.description      = <<-DESC
                       An optional longer description of Sensorberg

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/<GITHUB_USERNAME>/Sensorberg"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "tagyro" => "andrei.stoleru@gmail.com" }
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/Sensorberg.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.public_header_files     = 'Pod/Classes/**/*.h'
  s.resource_bundles = {
    'Sensorberg' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'JSONModel', '~> 1.1'
  s.dependency 'tolo','~> 1.0'
  s.dependency 'AFNetworking', '~> 2.0'
end
