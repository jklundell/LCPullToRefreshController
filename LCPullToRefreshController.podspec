Pod::Spec.new do |s|
  s.platform = :ios
  s.name = "LCPullToRefreshController"
  s.version = "1.0.0"
  s.summary = "Pull-to-refresh controller for UIScrollView."
  s.license = 'MIT'
  s.homepage = 'https://github.com/jklundell/LCPullToRefreshController'
  s.author = {
    'Jonathan Lundell' => 'jlundell@pobox.com'
  }
  s.source = {
    :git => 'https://github.com/jklundell/LCPullToRefreshController.git',
    :tag => 'v1.0.0'
  }
  s.source_files = 'PullToRefreshDemo/LCPullToRefreshController.{h,m}'
  s.requires_arc = true
end
