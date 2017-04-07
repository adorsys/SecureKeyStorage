Pod::Spec.new do |s|
  s.name = 'ADSecureDeviceStorage'
  s.version = '1.0.0'
  s.license = { :type => 'commercial', :file => 'LICENSE.txt' }
  s.summary = 'Library for storing sensitive data securely on iOS devices.'
  s.homepage = 'https://github.com/adorsys/secure-key-storage/tree/master/secure-device-storage/sds-ios'
  s.author = { 'adorsys' => 'info@adorsys.de' }
  s.source = {
    # TODO: Find out how to point to the git subfolder
    :git => 'https://github.com/adorsys/secure-key-storage.git',
    :tag => s.version.to_s
  }

  # Platform setup
  s.requires_arc = true
  s.ios.deployment_target = '9.0'
  s.source_files = 'Sources/**/*.{swift}'

  # Dependencies
  s.dependency 'RNCryptor', '~> 5.0'

end
