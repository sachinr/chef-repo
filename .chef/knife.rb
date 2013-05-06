require 'librarian/chef/integration/knife'
current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "siyelo"
client_key               "#{current_dir}/siyelo.pem"
validation_client_name   "siyelo-validator"
validation_key           "#{current_dir}/siyelo-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/siyelo"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            [Librarian::Chef.install_path,
                          "#{current_dir}/../my_cookbooks"]

knife[:aws_access_key_id]     = "#{ENV['AMAZON_ACCESS_KEY_ID']}"
knife[:aws_secret_access_key] = "#{ENV['AMAZON_SECRET_ACCESS_KEY']}"
