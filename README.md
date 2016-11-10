# sparkle-pack-aws-my-subnets
SparklePack to auto-detect subnets within a certain VPC.  The VPC must have an "Environment" tag,
where its value probably matches a Chef environment or something equivalent.

h/t to [techshell](https://github.com/techshell) for this approach.

## Use Cases
This SparklePack adds a registry entry that uses the AWS SDK to detect the subnets within your VPC
(based on `ENV['AWS_REGION']` and `ENV['environment']`) and returns arrays.  The arrays are
`my_public_subnet_ids`, `my_public_subnet_names`, `my_private_subnet_ids`, and `my_private_subnet_names`.

Private / Public subnets are denoted by 'Network' tags, which are set to either 'Private' or 'Public.'
Otherwise, in the default VPC, private and public subnets are simply the default subnets in
the VPC.

For the `my_public_subnet_names` and `my_private_subnet_names` registries to work, your subnets
must have "Name" tags.

## Usage
Add the pack to your Gemfile and .sfn:

Gemfile:
```ruby
source 'https://rubygems.org'

gem 'sfn'
gem 'sparkle-pack-aws-my-subnets'
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
public_subnets registry!(:my_public_subnet_ids)
```
The `public_subnets` registry will return an array of Subnet IDs
