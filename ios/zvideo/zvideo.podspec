

Pod::Spec.new do |s|

 

  s.name         = "zvideo"
  s.version      = "0.0.1"
  s.summary      = "Handle some data."
  s.description  = <<-DESC
                    Handle the data.
                   DESC

  s.homepage     = "http://csdn.net/veryitman"
  s.license      = "MIT"
  s.author             = { "veryitman" => "362675035@qq.com" }
  s.source =  { :path => '.' }
  s.source_files  = "Source", "**/**/*.{h,m,mm,c}"
  s.resources = '*.bundle'
  s.ios.vendored_libraries = '*.a'
  s.ios.vendored_frameworks = '*.framework'
  s.resources = 'resources/storyboard/**','resources/images/**','resources/xib/**','*.bundle'
 
  s.exclude_files = "Source/Exclude"
   
  s.dependency 'farwolf.weex'  
  #s.dependency 'MCPlayerKit/GeneralPlayerUI'
  #s.dependency 'SJVideoPlayer'
   #s.dependency 'CTVideoPlayerView', '~> 1.4.5'
   #s.dependency "DFVideoPlayer"
  s.platform  = :ios, "8.0"
  
  s.frameworks = 'SystemConfiguration', 'CoreTelephony', 'UIKit', 'Foundation', 'CFNetwork','Security'
  s.libraries = "z", "sqlite3.0"
  s.requires_arc  = true


end
