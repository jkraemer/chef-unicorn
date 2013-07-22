#
# Cookbook Name:: unicorn
# Recipe:: default
#

include_recipe 'ruby'
package 'sudo'
package 'runit'

gem_package 'unicorn' do
  gem_binary node[:ruby][:gem]
end

directory '/etc/unicorn'
template '/etc/init.d/unicorn' do
  source 'unicorn_init.erb'
  mode 0755
  owner 'root'
  group 'root'
end

service "unicorn" do
  supports :reload => true, :restart => true
  reload_command "/etc/init.d/unicorn reload"
  action :enable
end


