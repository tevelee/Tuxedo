Pod::Spec.new do |s|
  s.name = "Tuxedo"
  s.version = "1.0.0"
  s.summary = "Tuxedo is a template language for Swift"
  s.description = <<-DESC
Tuxedo is a template language for Swift. 
It allows you to separate the UI and rendering layer of your application from the business logic. 
Smart templates working with raw data allow the frontend to be handled and developed separately from other parts of the application, so processing, layouting and formatting your output can be defined in very simple template formats.
DESC
  s.homepage = "https://tevelee.github.io/Tuxedo/"
  s.license = { :type => "Apache 2.0", :file => "LICENSE.txt" }
  s.author = { "Laszlo Teveli" => "tevelee@gmail.com" }
  s.social_media_url = "http://twitter.com/tevelee"
  s.source = { :git => "https://github.com/tevelee/Tuxedo.git", :tag => "#{s.version}" }
  s.source_files = "Sources/**/*.{h,swift}"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.dependency "Eval", "~> 1.3.0"
end
