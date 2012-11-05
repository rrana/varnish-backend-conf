require 'rubygems'
require 'aws-sdk'

AWS.config(
    :access_key_id => 'ACCESSKEY',
    :secret_access_key => 'SECRETKEY',
    :auto_scaling_endpoint => 'autoscaling.eu-west-1.amazonaws.com',
    :ec2_endpoint => 'ec2.eu-west-1.amazonaws.com')

ec2 = AWS::AutoScaling.new

groups = ec2.groups
instances = []

ec2.groups.each do |group|
  if group.name == 'prod-group'
    group.auto_scaling_instances.each do |instance|
      instances.push(AWS::EC2::Instance.new(instance.id).private_ip_address)
    end
  end
end

nodes_num = 0

instances.each do |instance|
  puts "backend node#{nodes_num.to_s} {
    .host = \"#{instance}\";
    .port = \"8080\";
    .probe = healthcheck;
  }\n"
  nodes_num += 1
end

puts "director cluster random {"
(0..nodes_num-1).each { |i| puts "{ .backend = node#{i}; .weight = 1; }" }
puts "}"
