#
#  Be sure to run `pod spec lint Outletgen.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|


  s.name         = "Outletgen"
  s.version      = "0.0.4"
  s.summary      = "@IBOutlet, what is that?"
  s.author       = { "Michal Ciurus" => "http://michalciur.us/" }



  s.homepage     = "https://github.com/michalciurus/Outletgen"
  s.license      = { :type => "MIT", :file => "LICENSE" }



  s.source       = { :git => "https://github.com/michalciurus/Outletgen.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.resource = 'Outletgen'


end
