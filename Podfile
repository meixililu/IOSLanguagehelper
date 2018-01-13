source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'Languagehelper' do
pod 'Alamofire'
pod 'AlamofireObjectMapper'
pod 'Kingfisher'
#pod 'SnapKit', '~> 4.0'
pod 'SwiftyJSON'
pod 'Kanna'
pod 'RealmSwift'
pod 'LeanCloud'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
#            config.build_settings['SWIFT_VERSION'] = '4.0'
        end
    end
end

#post_install do |installer|
#    installer.pods_project.targets.each do |target|
#        target.build_configurations.each do |config|
#            config.build_settings['SWIFT_VERSION'] = '3.0'
#        end
#    end
#end

