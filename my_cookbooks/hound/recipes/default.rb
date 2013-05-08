#
# Cookbook Name:: hound
# Recipe:: default
#
# Copyright 2013, Example Com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


include_recipe 'apt'
include_recipe 'ruby_build'

ruby_build_ruby '1.9.3-p362' do
  prefix_path '/usr/local/'
  environment 'CFLAGS' => '-g -O2'
  action :install
end

include_recipe 'redisio::install'
include_recipe 'redisio::enable'
include_recipe 'postgresql::server'
include_recipe 'postgresql::client'
include_recipe 'postgresql::ruby'
include_recipe "runit"
include_recipe "database"

gem_package 'bundler' do
  version '1.2.3'
  gem_binary '/usr/local/bin/gem'
  options '--no-ri --no-rdoc'
end

postgresql_database 'hound_prod' do
  connection ({:host => "127.0.0.1", :port => 5432})
  action :create
end

postgresql_database_user 'hound_prod' do
  connection ({:host => "127.0.0.1", :port => 5432})
  password 'hound_prod'
  action :create
end

#ruby ssh_known_hosts_entry 'github.com'

bash 'add github to known_hosts' do
  code 'sudo ssh-keyscan -H github.com > /etc/ssh/ssh_known_hosts'
end

application 'app' do
  owner 'ubuntu'
  group 'ubuntu'
  path '/home/ubuntu/app'
  revision 'master'
  repository 'git@github.com:siyelo/Hound.git'
  environment_name 'production'
  rails do
    bundler true
  end
end

template "/home/ubuntu/app/current/config/database.yml" do
  source 'database.yml.erb'
  owner 'ubuntu'
  group 'ubuntu'
  mode "644"
end

bash 'remove test rake task' do
  code 'rm -f /home/ubuntu/app/current/lib/tasks/test.rake'
end

bash 'precompile assets' do
  code 'cd /home/ubuntu/app/current/'
  code 'rake assets:precompile'
end

bash 'export upstart' do
  code 'cd /home/ubuntu/app/current/'
  code 'sudo bundle exec foreman export upstart hound_script -a hound -u ubuntu'
  code 'sudo cp hound_script/* /etc/init/'
  code "rm -rf hound_script"
  code "sudo sed -i \"1 i start on runlevel [2345]\" /etc/init/hound.conf"
  code "sudo start hound"
  code "sudo RAILS_ENV=production unicorn -p 80 -c config/unicorn.rb"
end
