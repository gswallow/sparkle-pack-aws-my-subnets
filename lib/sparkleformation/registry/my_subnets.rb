require 'aws-sdk-core'

my_vpc = ::String.new
my_subnets = ::Array.new
public_subnets = Array.new
private_subnets = ::Array.new
ec2 = ::Aws::EC2::Client.new

ec2.describe_vpcs.vpcs.each do |vpc|
  if !vpc.tags.keep_if{ |tag| tag.key.capitalize == "Environment" && tag.value == ENV['environment'] }.empty?
    my_vpc = vpc.vpc_id
    my_subnets = ec2.describe_subnets.subnets.map { |sn| sn if sn.vpc_id == my_vpc }.compact
    public_subnets = my_subnets.collect { |sn| sn if !sn.tags.find_index { |tag| tag.key.capitalize == "Network" && tag.value.capitalize == "Public" }.nil? }.compact
    private_subnets = my_subnets.collect { |sn| sn if !sn.tags.find_index { |tag| tag.key.capitalize == "Network" && tag.value.capitalize == "Private" }.nil? }.compact
  end
end

if my_vpc.empty?
  my_vpc = ec2.describe_vpcs.vpcs.collect { |vpc| vpc.vpc_id if vpc.is_default }.compact.first
  my_subnets = ec2.describe_subnets.subnets.map { |sn| sn if sn.vpc_id == my_vpc }.compact
  public_subnets = my_subnets
  private_subnets = my_subnets
end


SfnRegistry.register(:my_public_subnet_ids) do
  public_subnets.map(&:subnet_id)
end

SfnRegistry.register(:my_public_subnet_names) do
  public_subnets.map { |sn| sn.tags.map { |tag| tag.value if tag.key == "Name" }.compact }.flatten
end

SfnRegistry.register(:my_private_subnet_ids) do
  private_subnets.map(&:subnet_id)
end

SfnRegistry.register(:my_private_subnet_names) do
  private_subnets.map { |sn| sn.tags.map { |tag| tag.value if tag.key == "Name" }.compact }.flatten
end
