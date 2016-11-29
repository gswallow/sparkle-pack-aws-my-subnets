require 'aws-sdk-core'

my_vpc = ::String.new
ec2 = ::Aws::EC2::Client.new

ec2.describe_vpcs.vpcs.each do |vpc|
  if !vpc.tags.keep_if{ |tag| tag.key.capitalize == "Environment" && tag.value == ENV['environment'] }.empty?
    my_vpc = vpc.vpc_id
  end
end

if my_vpc.empty?
  my_vpc = ec2.describe_vpcs.vpcs.collect { |vpc| vpc.vpc_id if vpc.is_default }.compact.first
end


SfnRegistry.register(:my_vpc) do
  my_vpc
end
