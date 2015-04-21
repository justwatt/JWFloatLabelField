Pod::Spec.new do |s|
  s.name                = "JWFloatLabelField"
  s.version             = "1.0"
  s.summary             = "Swift impementation of a subclassed UITextField that allows the text fields label to still be present once the user starts to fill in a text field."
  s.homepage            = "https://github.com/justwatt/JWFloatLabelField"
  s.platform            = :ios, '8.0'
  s.source              = { :git => "https://github.com/justwatt/JWFloatLabelField", :tag => "1.0" }
  s.source_files        = 'UIFloatLabelTextField/*.{h,m}'
  s.requires_arc        = true
  s.social_media_url    = 'https://twitter.com/ArtSabintsev'
  s.screenshot          = 'http://share.hellosummit.com/image/2H3h2B0A1m0x/Screen%20Shot%202015-04-18%20at%207.32.59%20PM.png'
  s.author              = { "Justin Watt" => "justin@hellosummit.com" }
  s.license             = 'MIT'
end
