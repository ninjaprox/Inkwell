Pod::Spec.new do |s|
  s.name             = 'Inkwell'
  s.version          = '0.1.0'
  s.summary          = 'An inkwell to draw custom fonts on the fly.'
  s.description      = <<-DESC
                       In fact, Inkwell takes responsibilities for:
                       - Downloading fonts from Google Fonts or custom resources.
                       - Registering custom fonts to the system.
                       - Loading and using custom fonts dynamically and seamlessly.
                       All of these are wrapped in friendly, yet easy to use API. 
                       DESC

  s.homepage         = 'https://github.com/ninjaprox/Inkwell'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Vinh Nguyen' => 'ninjaprox@gmail.com' }
  s.source           = { :git => 'https://github.com/ninjaprox/Inkwell.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ninjaprox'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Inkwell/Classes/**/*'
  
  s.frameworks = 'Foundation'
  s.dependency 'Alamofire', '~> 4.4'
end
