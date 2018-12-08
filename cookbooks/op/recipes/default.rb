execute "apt-get-update" do
  command "apt-get -y update"
  ignore_failure true
end

execute "apt-get-upgrade" do
  command "DEBIAN_FRONTEND=noninteractive apt-get upgrade -y"
  ignore_failure true
end

user node['deploy_user'] do
	manage_home true
	comment 'A deploy user'
	home "/home/#{node['deploy_user']}"
	password node['deploy_password']
	shell '/bin/bash'
end

sudo node['deploy_user'] do
  users node['deploy_user']
  nopasswd true
end

directory "/home/#{node['deploy_user']}/.ssh/" do
	owner node['deploy_user']
	mode '0700'
end

directory "/home/#{node['deploy_user']}/#{node['sitename']}" do
	owner node['deploy_user']
	mode '0755'
	recursive true
end

directory "/home/#{node['deploy_user']}/#{node['sitename']}/shared" do
	owner node['deploy_user']
	mode '0755'
	recursive true
end

directory "/home/#{node['deploy_user']}/#{node['sitename']}/shared/config" do
	owner node['deploy_user']
	mode '0755'
	recursive true
end

template "/home/#{node['deploy_user']}/#{node['sitename']}/shared/config/database.yml" do
  source "database.yml.erb"
  owner node['deploy_user']
  mode '0755'
  variables(database_ip: node['database_ip'],
            database_name: node['database_name'],
            database_username: node['database_username'],
            database_password: node['database_password'],
            database_port: node['database_port'])
end

template "/home/#{node['deploy_user']}/#{node['sitename']}/shared/config/application.yml" do
  source "application.yml.erb"
  owner node['deploy_user']
  mode '0755'
end

cookbook_file "/home/#{node['deploy_user']}/.ssh/id_rsa" do
	source 'id_rsa_private'
	owner node['deploy_user']
	mode '0600'
	action :create_if_missing
end

cookbook_file "/home/#{node['deploy_user']}/.ssh/id_rsa.pub" do
	source 'id_rsa_public'
	owner node['deploy_user']
	mode '0644'
	action :create_if_missing
end

cookbook_file "/home/#{node['deploy_user']}/.ssh/authorized_keys" do
	source 'authorized_keys'
	owner node['deploy_user']
	mode '0644'
	action :create_if_missing
end

execute 'openjdk' do
  command 'apt install -y default-jdk'
end

package 'postgresql'
package 'postgresql-contrib'
package 'libpq-dev'

bash 'install_rvm' do
  user node['deploy_user']
  cwd "/home/#{node['deploy_user']}"
  code <<-EOH
    sudo su - #{node['deploy_user']} bash -c '
    cd $HOME;
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3;
	curl -sSL https://get.rvm.io | bash -s stable;
	. ~/.bash_profile;
	. $HOME/.rvm/scripts/rvm;
	rvm install #{node['ruby_version']};
	rvm --default use #{node['ruby_version']};
	'
  EOH
  not_if { ::File.exist?("/home/#{node['deploy_user']}/.rvm") }
end

package 'git'
package 'tree'

package 'nginx'

service 'nginx' do
  action [ :enable, :start ]
end

template "/etc/nginx/sites-available/default" do   
  source "sites_available.erb"
  notifies :reload, "service[nginx]"
  variables(sitename: node['sitename'])
end

include_recipe "nodejs"
