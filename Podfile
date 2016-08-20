source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target "Languagehelper" do
pod "Alamofire"
pod "AlamofireObjectMapper"
pod "Kingfisher"
pod "SnapKit"
pod "SwiftyJSON"
pod "Kanna"
pod "AsyncSwift"
pod "RealmSwift"
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end