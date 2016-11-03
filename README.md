# sparkle-pack-aws-my-subnets
SparklePack to auto-detect subnets within a VPC.  The VPC must have an "Environment" tag,
where its value probably matches a Chef environment or something equivalent.

h/t to [techshell](https://github.com/techshell) for this approach.

## Use Cases
This SparklePack adds a registry entry that uses the AWS SDK to detect the subnets within your VPC
(based on `ENV['AWS_REGION']` and `ENV['environment']`) and returns arrays.  The arrays are
`my_public_subnet_ids`, `my_public_subnet_names`, `my_private_subnet_ids`, and `my_private_subnet_names`.

Subnets must have "Name" tags.  This sparkle pack is a work in progress.

## Usage
Add the pack to your Gemfile and .sfn:

Gemfile:
```ruby
source 'https://rubygems.org'

gem 'sfn'
gem 'sparkle-pack-aws-aws-my-subnets'
```

.sfn:
```ruby
Configuration.new do
  sparkle_pack [ 'sparkle-pack-aws-my-subnets' ]
  ...
end
```

In a SparkleFormation Template/Component/Dynamic:
```ruby
public_subnets = registry!(:my_public_subnet_ids)
```
`public_subnets` will be an array of Subnet IDs
