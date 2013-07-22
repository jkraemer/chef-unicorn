default[:unicorn][:user] = 'www-data'
default[:unicorn][:restart_wait_seconds] = 10
default[:unicorn][:rack_env] = 'production'
default[:unicorn][:worker_processes] = 2 # this is per application
default[:unicorn][:preload_app] = true
default[:unicorn][:timeout] = 30
