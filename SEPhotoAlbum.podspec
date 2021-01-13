#
# Be sure to run `pod lib lint SEPhotoAlbum.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SEPhotoAlbum'
  s.version          = '0.3.0'
  s.summary          = 'photo album.'
  s.description      = 'swift photo album for iOS.'
  s.homepage         = 'https://github.com/seeEmil/SEPhotoAlbum'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'seeEmil' => '864009759@qq.com' }
  s.source           = { :git => 'https://github.com/seeEmil/SEPhotoAlbum.git', :tag => s.version.to_s }
  # s.pod_target_xcconfig = { 'VALID_ARCHS[sdk=iphonesimulator*]' => '' }
  s.ios.deployment_target = '10.0'
  
  s.swift_version = '5.0'
  
#  if ENV['is_source']
  s.source_files = 'SEPhotoAlbum/Classes/**/*'
#  else
#      s.vendored_frameworks = 'SEPhotoAlbum/Products/SEPhotoAlbum.framework'
#  end
  s.resource_bundles = {
     'SEPhotoAlbum' => ['SEPhotoAlbum/Assets/*.png']
  }
end
