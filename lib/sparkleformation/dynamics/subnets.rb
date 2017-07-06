require 'aws-sdk-core'

zones = ::Array.new
ec2 = ::Aws::EC2::Client.new
zones = ec2.describe_availability_zones.availability_zones.map(&:zone_name)

SparkleFormation.dynamic(:public_subnets) do |options = {}|
  route_table = options.fetch(:public_route_table, :default_ec2_route_table)

  parameters(:cidr_prefix) do
    type 'Number'
    min_value '16'
    max_value '31'
    default '16'
    description 'The prefix of the CIDR block to assign to the VPC (172.X.0.0/16)'
  end

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
               value "utility-#{zone}.k8s.#{ENV['public_domain']}"
#               value join!('public', zone, '172', ref!(:cidr_prefix), subnet, '0/20', {:options => { :delimiter => '-' }})
             },
             -> {
               key 'Network'
               value 'Public'
             },
             -> {
               key 'Environment'
               value ENV['environment']
             },
             -> {
               key 'KubernetesCluster'
               value "k8s.#{ENV['public_domain']}"
             },
             -> {
               key "kubernetes.io/cluster/k8s.#{ENV['public_domain']}"
               value "shared"
             }
           )
    end

    dynamic!(:ec2_subnet_route_table_association, "#{zone.gsub('-', '_')}_public").properties do
      subnet_id ref!("#{zone.gsub('-', '_')}_public_ec2_subnet".to_sym)
      route_table_id ref!(route_table)
    end

    dynamic!(:ec2_e_i_p, "#{zone.gsub('-', '_')}_nat").properties do
      domain 'vpc'
    end

    dynamic!(:ec2_nat_gateway, "#{zone.gsub('-', '_')}").properties do
      subnet_id ref!("#{zone.gsub('-', '_')}_public_ec2_subnet".to_sym)
      allocation_id attr!("#{zone.gsub('-', '_')}_nat_ec2_e_i_p".to_sym, 'AllocationId')
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
               value "#{zone}.k8s.#{ENV['public_domain']}"
               #value join!('private', zone, '172', ref!(:cidr_prefix), subnet, '0/20', {:options => { :delimiter => '-' }})
             },
             -> {
               key 'Network'
               value 'Private'
             },
             -> {
               key 'Environment'
               value ENV['environment']
             },
             -> {
               key 'KubernetesCluster'
               value "k8s.#{ENV['public_domain']}"
             },
             -> {
               key "kubernetes.io/cluster/k8s.#{ENV['public_domain']}"
               value "shared"
             }
           )
    end

    dynamic!(:ec2_route, "#{zone.gsub('-', '_')}_nat".to_sym).properties do
      destination_cidr_block '0.0.0.0/0'
      nat_gateway_id ref!("#{zone.gsub('-', '_')}_ec2_nat_gateway".to_sym)
      route_table_id ref!("#{zone.gsub('-', '_')}_private_ec2_route_table".to_sym)
    end

    dynamic!(:ec2_subnet_route_table_association, "#{zone.gsub('-', '_')}_private").properties do
      subnet_id ref!("#{zone.gsub('-', '_')}_private_ec2_subnet".to_sym)
      route_table_id ref!("#{zone.gsub('-', '_')}_private_ec2_route_table".to_sym)
    end
  end
end
