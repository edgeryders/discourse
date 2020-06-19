server 'edgeryders.eu', user: 'discourse', roles: [:web, :app, :db], primary: true

set :puma_bind, %w(tcp://0.0.0.0:9294 tcp://whitelabel.edgeryders.eu:9294 unix:///home/discourse/production_multisite/current/tmp/sockets/puma.sock)

# NOTE: Required as otherwise the generated service name would be "sidekiq__production.conf"
#set :sidekiq_monit_conf_file, -> { "sidekiq_#{fetch(:application)}_production.conf" }
