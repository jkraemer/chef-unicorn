#
# Cookbook Name:: unicorn
# Definition:: unicorn_app
#

define :unicorn_app, :init_cfg_template => 'unicorn_app.conf.erb',
                     :init_unicorn_template => 'unicorn_app.rb'  do

  app_name = params[:name]

  service "unicorn-#{app_name}" do
    supports :restart => true, :reload => true
    restart_command "/etc/init.d/unicorn restart #{app_name}"
    reload_command "/etc/init.d/unicorn reload #{app_name}"
    action :nothing
  end

  template "/etc/unicorn/#{app_name}.conf" do
    source params[:init_cfg_template]
    owner 'root'
    group 'root'
    mode 0644
    cookbook params[:cookbook] || 'unicorn'
    variables :app_root => params[:app_root],
              :user => params[:user],
              :start_cmd => params[:start_cmd],
              :rack_env => params[:rack_env] || 'production',
              :user => params[:user] || node[:unicorn][:user],
              :group => params[:group] || node[:unicorn][:group],
              :listen => params[:listen],
              :ruby => params[:ruby],
              :workers => params[:workers] || 2,
              :config => "/etc/unicorn/#{app_name}.unicorn.rb"
    notifies :restart, "service[unicorn-#{app_name}]"
  end

  cookbook_file "/etc/unicorn/#{app_name}.unicorn.rb" do
    source params[:init_unicorn_template]
    cookbook params[:cookbook] || 'unicorn'
    owner 'root'
    group 'root'
    mode 0644
    notifies :restart, "service[unicorn-#{app_name}]"
  end

end
