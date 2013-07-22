#
# Cookbook Name:: unicorn
# Definition:: unicorn_app
#

define :unicorn_app, :init_cfg_template => 'unicorn_app.conf.erb',
                     :init_unicorn_template => 'unicorn_app.rb.erb'  do

  app_name = params[:name]

  service "unicorn-#{app_name}" do
    supports :restart => true, :reload => true
    restart_command "/etc/init.d/unicorn restart #{app_name}"
    reload_command "/etc/init.d/unicorn upgrade #{app_name}"
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
              :user => params[:user] || node[:unicorn][:user]
    notifies :restart, "service[unicorn-#{app_name}]"
  end

  template "/etc/unicorn/#{app_name}.unicorn.rb" do
    source params[:init_unicorn_template]
    owner 'root'
    group 'root'
    mode 0644
    cookbook params[:cookbook] || 'unicorn'
    variables :app_root => params[:app_root],
              :rack_env => params[:rack_env] || node[:unicorn][:rack_env],
              :listen => params[:listen],
              :worker_processes => params[:worker_processes] || node[:unicorn][:worker_processes],
              :preload_app => params.key?(:preload) ? params[:preload] : node[:unicorn][:preload],
              :timeout => params[:timeout] || node[:unicorn][:timeout]
    notifies :restart, "service[unicorn-#{app_name}]"
  end

end
