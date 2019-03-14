Pod::Spec.new do |s|
  s.name = 'SecureKeyStorage'
  s.version = '0.1.0'
  s.license = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.summary = 'Library for storing sensitive data securely on iOS devices.'
  s.homepage = 'https://github.com/adorsys/secure-banking-ios'
  s.author = { 'adorsys GmbH & Co. KG' => 'dev.team.ios@adorsys.de' }
  s.source = {
    :git => 'https://github.com/adorsys/secure-banking-ios.git',
    :tag => s.version.to_s
  }

  # Platform setup
  s.requires_arc = true
  s.ios.deployment_target = '9.0'
  s.source_files = 'Sources/Classes/**/*'
  s.swift_version = '4.2'

  # Dependencies
  s.dependency 'RNCryptor', '~> 5.0'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/*.swift'
  end
end
