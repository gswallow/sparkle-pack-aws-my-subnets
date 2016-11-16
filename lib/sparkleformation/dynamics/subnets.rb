require 'aws-sdk-core'

zones = ::Array.new
ec2 = ::Aws::EC2::Client.new
zones = ec2.describe_availability_zones.availability_zones.map(&:zone_name)

SparkleFormation.dynamic(:public_subnets) do |options = {}|
  route_table = options.fetch(:public_route_table, :default_ec2_route_table)
  zones.each do |zone|
    subnet = ((zone[-1].ord - 'a'.ord) * 16).to_s

    dynamic!(:ec2_subnet, "#{zone.gsub('-', '_')}_public").properties do
      vpc_id ref!(:vpc)
      availability_zone zone
      cidr_block join!( join!( '172', ref!(:cidr_prefix), subnet, '0', {:options => {:delimiter => '.'}}), '20', {:options => {:delimiter => '/'}})
      map_public_ip_on_launch options.fetch(:map_public_ips, 'false')
      tags _array(
             -> {
               key 'Name'
               value join!('public', zone, '172', ref!(:cidr_prefix), subnet, '0/20', {:options => { :delimiter => '-' }})
             },
             -> {
               key 'Network'
               value 'Public'
             },
             -> {
               key 'Environment'
               value ENV['environment']
             }
           )
    end

    dynamic!(:ec2_subnet_route_table_association, "#{zone.gsub('-', '_')}_public").properties do
      subnet_id ref!("#{zone.gsub('-', '_')}_public_ec2_subnet".to_sym)
      route_table_id ref!(route_table)
    end
  end
end

SparkleFormation.dynamic(:private_subnets) do |options = {}|
  zones.each do |zone|
    subnet = (240 - ((zone[-1].ord - 'a'.ord) * 16)).to_s

    dynamic!(:ec2_route_table, "#{zone.gsub('-', '_')}_private").properties do
      vpc_id ref!(:vpc)
      tags _array(
        -> {
          key 'Name'
          value "#{zone.gsub('-', '_')}_private_route_table".to_sym
        }
      )
    end

    dynamic!(:ec2_subnet, "#{zone.gsub('-', '_')}_private").properties do
      vpc_id ref!(:vpc)
      availability_zone zone
      cidr_block join!( join!( '172', ref!(:cidr_prefix), subnet, '0', {:options => {:delimiter => '.'}}), '20', {:options => {:delimiter => '/'}})
      tags _array(
             -> {
               key 'Name'
               value join!('private', zone, '172', ref!(:cidr_prefix), subnet, '0/20', {:options => { :delimiter => '-' }})
             },
             -> {
               key 'Network'
               value 'Private'
             },
             -> {
               key 'Environment'
               value ENV['environment']
             }
           )
    end

    dynamic!(:ec2_subnet_route_table_association, "#{zone.gsub('-', '_')}_private").properties do
      subnet_id ref!("#{zone.gsub('-', '_')}_private_ec2_subnet".to_sym)
      route_table_id ref!("#{zone.gsub('-', '_')}_private_ec2_route_table".to_sym)
    end
  end
end