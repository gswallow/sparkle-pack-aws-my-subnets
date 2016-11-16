require 'aws-sdk-core'

zones = ::Array.new
ec2 = ::Aws::EC2::Client.new
zones = ec2.describe_availability_zones.availability_zones.map(&:zone_name)

SfnRegistry.register(:public_subnets_ref_list) do
  zones.map { |zone| ref!("#{zone.gsub('-', '_')}_public_ec2_subnet") }
end

SfnRegistry.register(:private_subnets_ref_list) do
  zones.map { |zone| ref!("#{zone.gsub('-', '_')}_private_ec2_subnet") }
end
