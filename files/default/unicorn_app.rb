# Safeguard to prevent us from configuration mistakes
if Process.euid == 0
  $stderr.puts "Unicorns don't like to run as root. Please use a non-proviliged user!"
  exit 1
end

APP_ROOT = ENV['APP_ROOT'] || File.expand_path('../..', __FILE__)
RAILS_ENV = ENV['RACK_ENV'] || 'production'

gemfile = File.join APP_ROOT, 'Gemfile'
if File.readable?(gemfile)
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler/setup'
end

working_directory APP_ROOT
worker_processes (ENV['UNICORN_WORKERS'] || 2).to_i
preload_app true
timeout 60

# Enable this flag to have unicorn test client connections by writing the
# beginning of the HTTP headers before calling the application.  This
# prevents calling the application for connections that have disconnected
# while queued.  This is only guaranteed to detect clients on the same
# host unicorn runs on, and unlikely to detect disconnects even on a
# fast LAN.
check_client_connection true

if ENV['LISTEN']
  listen ENV['LISTEN']
else
  listen APP_ROOT + "/tmp/pids/unicorn.sock", :backlog => 64
end
pid    ENV['UNICORN_PID'] || File.join(APP_ROOT, "tmp/pids/unicorn.pid")

stderr_path File.join(APP_ROOT, "log/unicorn.stderr.log")
stdout_path File.join(APP_ROOT, "log/unicorn.stdout.log")

before_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      puts "Old master already dead"
    end
  end

  # dont fork too fast
  sleep 1
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
  child_pid = server.config[:pid].sub('.pid', ".#{worker.nr}.pid")
  system("echo #{Process.pid} > #{child_pid}")
end

