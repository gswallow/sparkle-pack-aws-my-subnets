Gem::Specification.new do |s|
  s.name = 'sparkle-pack-aws-my-subnets'
  s.version = '0.0.1'
  s.licenses = ['MIT']
  s.summary = 'AWS My Subnets SparklePack'
  s.description = 'SparklePack to detect subnets in a VPC whose Environment tag matches the "environment" environment variable.'
  s.authors = ['Greg Swallow']
  s.email = 'gswallow@indigobio.com'
  s.homepage = 'https://github.com/gswallow/sparkle-pack-aws-my-subnets'
  s.files = Dir[ 'lib/sparkleformation/registry/*' ] + %w(sparkle-pack-aws-my-subnets.gemspec lib/sparkle-pack-aws-my-subnets.rb)
  s.add_runtime_dependency 'aws-sdk-core', '~> 2'
end
