target 'RentBike' do

platform:ios, '12.0'
use_frameworks!
inhibit_all_warnings!

# Network
pod 'Alamofire'
pod 'AlamofireImage'
pod 'SwiftyJSON'
pod 'ObjectMapper'
pod 'SDWebImage'
# UI
pod 'Spring', :git => 'https://github.com/MengTo/Spring.git'

pod 'SQLite.swift' # datastorage

pod 'Firebase/AppDistribution'
pod 'Firebase/Auth'
pod 'GoogleSignIn'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
            config.build_settings['CLANG_ENABLE_OBJC_WEAK'] ||= 'YES'
        end
    end
end

end
