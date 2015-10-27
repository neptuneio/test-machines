#!/bin/bash

# ENV variables
SYSTEM_HOSTNAME=`hostname`

# Work out of ubuntu user home
cd /home/ubuntu

# Install test worker job process
curl -sS -o neptune_test_worker_job.sh https://raw.githubusercontent.com/neptuneio/test-machines/master/worker_job/neptune_test_worker_job.sh
chmod +x neptune_test_worker_job.sh
chown -R ubuntu:ubuntu neptune_test_worker_job.sh
nohup /home/ubuntu/neptune_test_worker_job.sh&

# Install staging version of Neptuneio agent pointing to dev-gamma account in dev/staging
NAGENT_USER=ubuntu NEPTUNE_ENDPOINT="neptune-staging-env.herokuapp.com" NEPTUNEIO_KEY="3052843476f74f5db8f50d6708528d88" bash -c "$(curl -sS -L https://raw.githubusercontent.com/neptuneio/nagent/staging/src/install_nagent.sh)"

# Install required python modules for some of our rules.
pip install texttable

# Install datadog agent
DD_API_KEY=480944a4de7c042d7632983a7f5f7fa8 bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh)"
# Process yaml
curl -sS -o /etc/dd-agent/conf.d/process.yaml https://raw.githubusercontent.com/neptuneio/test-machines/master/datadog/process.yaml
service datadog-agent restart

# Install scout agent
apt-get install -y ruby
cd /home/ubuntu
curl -Sso scout_install.sh https://scoutapp.com/scout_install.sh && sudo /bin/bash ./scout_install.sh -y -k 5S3e2mIKqSi1NfSGJqQcjjt7bxoUfncYa3O9lF5L

# Install Sensu agent
wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | apt-key add -
echo "deb http://repos.sensuapp.org/apt sensu main" | tee -a /etc/apt/sources.list.d/sensu.list
apt-get update && apt-get install -y sensu

# Get config/client jsons
curl -Sso /etc/sensu/config.json https://raw.githubusercontent.com/neptuneio/test-machines/master/sensu/config.json
curl -Sso /etc/sensu/conf.d/client.json https://raw.githubusercontent.com/neptuneio/test-machines/master/sensu/client.json
sed -i "s|client_name|$SYSTEM_HOSTNAME|g" /etc/sensu/conf.d/client.json
sed -i "s|client_address|$SYSTEM_HOSTNAME|g" /etc/sensu/conf.d/client.json

# Set embedded ruby =true in sensu default configuration
sed -i "s|EMBEDDED_RUBY=\S\+|EMBEDDED_RUBY=true|g" /etc/default/sensu

# Download required sensu checks to plugins directory
curl -Sso /etc/sensu/plugins/check-nagent.rb https://raw.githubusercontent.com/neptuneio/test-machines/master/sensu/plugins/check-nagent.rb
chmod +x /etc/sensu/plugins/check-nagent.rb

curl -Sso /etc/sensu/plugins/check-mem.sh https://sensuapp.org/docs/0.18/files/check-mem.sh
chmod +x /etc/sensu/plugins/check-mem.sh

curl -Sso /etc/sensu/plugins/check-procs.rb https://raw.githubusercontent.com/sensu/sensu-community-plugins/master/plugins/processes/check-procs.rb
chmod +x /etc/sensu/plugins/check-procs.rb

curl -Sso /etc/sensu/plugins/cpu-metrics.rb https://raw.githubusercontent.com/sensu/sensu-community-plugins/master/plugins/system/cpu-metrics.rb
chmod +x /etc/sensu/plugins/cpu-metrics.rb

# Ensure sensu checks and plugins are owned by sensu user and group
chown -R sensu:sensu /etc/sensu

# Start sensu client
/etc/init.d/sensu-client start

# Install zabbix agent
apt-get install -y zabbix-agent
sed -i 's|Server=\S\+|Server=54.149.32.142|g' /etc/zabbix/zabbix_agentd.conf
sed -i 's|ServerActive=\S\+|ServerActive=54.149.32.142|g' /etc/zabbix/zabbix_agentd.conf
sed -i 's|Hostname=\S\+||g' /etc/zabbix/zabbix_agentd.conf
sed -i 's|# HostnameItem=system.hostname|HostnameItem=system.hostname|g' /etc/zabbix/zabbix_agentd.conf
service zabbix-agent restart

# Nagios setup 
# Install nginx
apt-get install -y nginx
service nginx restart

# Install mysql so that Nagios monitors it.
debconf-set-selections <<< 'mysql-server mysql-server/root_password password neptunerocks'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password neptunerocks'
apt-get install -y mysql-server
sed -i 's|bind-address|#bind-address|g' /etc/mysql/my.cnf
service mysql restart

# Install stress package
apt-get install -y stress

# Initialize stress load with 6 min duty cycle
cd /home/ubuntu
killall stress_load.sh
curl -sS -o stress_load.sh https://raw.githubusercontent.com/neptuneio/test-machines/master/stress/stress_load.sh
chmod +x ./stress_load.sh
nohup ./stress_load.sh > /dev/null 2>&1 &

# Install New relic agent
# Use unbuntu version of new relic agent
echo "deb http://apt.newrelic.com/debian/ newrelic non-free" > /etc/apt/sources.list.d/newrelic.list
wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -
apt-get update
apt-get install -y newrelic-sysmond

# Use staging NewRelic license key
nrsysmond-config --set license_key=cfcd0111fc31afb2c92e00bc06ca0fc1a4882825
/etc/init.d/newrelic-sysmond restart

# Install nodejs app and start it for newrelic application testing
cd /home/ubuntu
rm -rf newrelicTestApp /tmp/temp.file
git clone https://github.com/stalluri/newrelicTestApp.git
chown -R ubuntu:ubuntu newrelicTestApp
nohup /usr/local/bin/node ./newrelicTestApp/server.js > ./newrelicTestApp/server.log 2>&1 &

