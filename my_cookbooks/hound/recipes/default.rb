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
#
include_recipe 'apt'
include_recipe 'ruby_build'
include_recipe 'redisio::install'
include_recipe 'redisio::enable'
include_recipe 'postgresql'
include_recipe 'postgresql::ruby'
include_recipe "runit"

ruby_build_ruby '1.9.3-p362' do
  prefix_path '/usr/local/'
  environment 'CFLAGS' => '-g -O2'
  action :install
end

gem_package 'bundler' do
  version '1.2.3'
  gem_binary '/usr/local/bin/gem'
  options '--no-ri --no-rdoc'
end

#pg_user "hound_prod" do
  #privileges :superuser => false, :createdb => false, :login => true
  #encrypted_password "643097a6d836edb48c71c780a6db0fa8"
#end

#pg_database "hound_prod" do
  #owner "hound_prod"
  #encoding "utf8"
  #locale "en_US.UTF8"
#end

## we create new user that will run our application server
#user_account 'deployer' do
  #create_group true
  #ssh_keygen false
#end

ruby ssh_known_hosts_entry 'github.com'

# we define our application using application resource provided by application cookbook
application 'app' do
  owner 'ubuntu'
  #group 'deployer'
  path '/home/ubuntu/app'
  revision 'master'
  repository 'git@github.com:siyelo/Hound.git'
  rails do
    bundler true
  end
end
