# sparkle-pack-aws-my-subnets
SparklePack to auto-detect and create subnets within a certain VPC.
We identify AWS resources by tags.

h/t to [techshell](https://github.com/techshell) for this approach.

## Tags

Everything that gets created on AWS has an `Environment` tag.  These tags
generally match Chef environemnts, or "stacks."

VPCs are assigned some tags:
  - `Environment`
  - `Name`

Subnets are also assigned some tags:
  - `Network`: either "Public" or "Private"
  - `Environment`
  - `Name` 

## Environment variables

The following environment variables must be set in order to use this Sparkle
Pack:

- AWS_REGION
- AWS_DEFAULT_REGION (being deprecated?)
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_CUSTOMER_ID (optional)
- environment

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

### Registries
In a SparkleFormation Template/Component/Dynamic:
```ruby
data!['VPCZoneIdentifier'] = registry!(:public_subnets_ref_list)
```

The `public_subnets_ref_list` and `private_subnets_ref_list` registries
simply return AWS ref! intrinsic functions, which point to predictably
named AWS::EC2::Subnet resources.  These registries are intended for use
when creating a VPC and its subnets (as in, the subnets aren't created
yet).

```ruby
public_subnets registry!(:my_public_subnet_ids)
```

The `my_public_subnet_ids` registry will return an array of Subnet IDs where
each subnet's `Network` tag is set to 'Public.'  Likewise, the
`my_private_subnet_ids` registry will return Subnet IDs of private subnets.

If your public and private subnets have `Name` tags, then the 
`my_public_subnet_names` and `my_private_subnet_names` registries
will return subnets' names.

### Dynamics

The `public_subnets` and `private_subnets` dynamics create as many 
private and public subnets as there are availability zones in
ENV['AWS_REGION']:

```ruby
dynamic!(:public_subnets)
dynamic!(:private_subnets)
```

There are two options:

- `:map_public_ips` sets the default behavior for mapping public IPs
to instances within a public subnet
- `:public_route_table` could be overridden, changing the name of the public
route table resource's name, but I don't see why one would do that.