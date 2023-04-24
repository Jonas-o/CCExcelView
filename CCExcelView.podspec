#
#  Be sure to run `pod spec lint CCExcelView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "CCExcelView"
  s.version      = "1.0.6"
  s.summary      = "The Excel View a friendly way for iOS."
  s.description  = <<-DESC
                  iOS ExcelView 自定义表格，支持设置左右向锁住的列数，支持列排序（排序规则自己实现）,支持设置topView，支持列表背景色，支持设置整行还是单元格点击的点击色
                   DESC

  s.homepage     = "https://github.com/Jonas-o/CCExcelView"
  s.license      = { :type => "MIT", :file => "LICENSE"}
  s.author       = { "luo" => "luo_ty@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/Jonas-o/CCExcelView.git", :tag => s.version.to_s }
  s.framework = "UIKit"
  s.requires_arc = true

  s.source_files  = "CCViews", "CCExcelView/**/*.{h,m}"
  s.resource = "CCExcelView/CCResources/*.bundle"
  s.user_target_xcconfig = {
    'GENERATE_INFOPLIST_FILE' => 'YES'
  }
  s.pod_target_xcconfig = {
    'GENERATE_INFOPLIST_FILE' => 'YES'
  }


end
