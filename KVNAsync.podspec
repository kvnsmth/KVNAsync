Pod::Spec.new do |s|
  s.name         = "KVNAsync"
  s.version      = "0.1.0"
  s.summary      = "KVNAsync is a lightweight library for handling asynchrounous tasks and eventual values."
  s.homepage     = "https://github.com/kvnsmth/KVNAsync"
  s.license   = {
    :type => 'MIT',
    :file => 'LICENSE'
  }
  s.author       = { "Kevin Smith" => "kevin@kevinsmith.cc" }
  s.source       = { :git => "https://github.com/kvnsmth/KVNAsync.git", :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.source_files = 'KVNAsync'
end
