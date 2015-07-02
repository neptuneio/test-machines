#!/bin/bash

# Work out of ubuntu user home
cd /home/ubuntu

# Install Prod version of Neptuneio agent pointing to staging
NEPTUNE_ENDPOINT="neptune-staging-env.herokuapp.com" NEPTUNEIO_KEY="a976fc9fb8364cc99616e305486173ae" bash -c "$(curl -sS -L https://raw.githubusercontent.com/neptuneio/nagent/prod/src/install_nagent.sh)"

# Install New relic agent
# Use unbuntu version of new relic agent
echo deb http://apt.newrelic.com/debian/ newrelic non-free >> /etc/apt/sources.list.d/newrelic.list
wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -
apt-get update
apt-get install -y newrelic-sysmond
nrsysmond-config --set license_key=dfc748af2b5d0a493659d3a443a7bc2fdbe06fa1
/etc/init.d/newrelic-sysmond start

# Install nodejs app and start it for newrelic application testing
cd /home/ubuntu
rm -rf newrelicTestApp /tmp/temp.file
git clone https://github.com/stalluri/newrelicTestApp.git
nohup node ./newrelicTestApp/server.js > ./newrelicTestApp/server.log 2>&1 &

# Install datadog agent
DD_API_KEY=480944a4de7c042d7632983a7f5f7fa8 bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh)"

# Install scout agent
apt-get install -y ruby
cd /home/ubuntu
curl -Sso scout_install.sh https://scoutapp.com/scout_install.sh && sudo /bin/bash ./scout_install.sh -y -k 5S3e2mIKqSi1NfSGJqQcjjt7bxoUfncYa3O9lF5L

# Install Sensu agent


# Install zabbix agent
apt-get install zabbix-agent
sed -i '' 's|Server=127.0.0.1|Server=52.27.165.226|g' /etc/zabbix/zabbix_agentd.conf
sed -i '' 's|Hostname=Zabbix server||g' /etc/zabbix/zabbix_agentd.conf
sed -i '' 's|# HostnameItem=system.hostname|HostnameItem=system.hostname|g' /etc/zabbix/zabbix_agentd.conf

# Install Nagios agent


# Install logic monitor agent


# Install stress package
apt-get -y install stress

# Initialize stress load with 6 min duty cycle
cd /home/ubuntu
killall stress_load.sh
curl -sS -o stress_load.sh https://raw.githubusercontent.com/neptuneio/test-machines/master/stress_load.sh
chmod +x ./stress_load.sh
nohup ./stress_load.sh > /dev/null 2>&1 &
