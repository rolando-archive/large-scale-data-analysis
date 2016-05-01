#!/usr/bin/env bash


# CDH Setup steps based on http://www.cloudera.com/documentation/cdh/5-1-x/CDH5-Quick-Start/cdh5qs_yarn_pseudo.html

cat > /etc/apt/sources.list.d/cloudera.list <<EOF
deb [arch=amd64] http://archive.cloudera.com/cdh5/ubuntu/precise/amd64/cdh precise-cdh5 contrib
deb-src http://archive.cloudera.com/cdh5/ubuntu/precise/amd64/cdh precise-cdh5 contrib
EOF
wget -O - http://archive.cloudera.com/cdh5/ubuntu/precise/amd64/cdh/archive.key | apt-key add -

apt-get update

# Install ALL THE THINGS
apt-get install -y openjdk-7-jdk hadoop-conf-pseudo curl vim tmux python-dev python-pip libyaml-dev

chown hadoop /var/log/hadoop-*

# Format HDFS
echo "****** Format HDFS ********"
sudo -u hdfs hdfs namenode -format

# Start all of the hadoops
echo "****** START ALL OF THE HADOOPS ********"
for x in `cd /etc/init.d ; ls hadoop-hdfs-*` ; do sudo service $x start ; done

# Setup HDFS directories and permissions
echo "****** SETUP HDFS DIRECTIRIES AND PERMISSIONS ********"
sudo -u hdfs hadoop fs -mkdir -p /tmp/hadoop-yarn/staging/history/done_intermediate
sudo -u hdfs hadoop fs -chown -R mapred:mapred /tmp/hadoop-yarn/staging
sudo -u hdfs hadoop fs -chmod -R 1777 /tmp
sudo -u hdfs hadoop fs -mkdir -p /var/log/hadoop-yarn
sudo -u hdfs hadoop fs -chown yarn:mapred /var/log/hadoop-yarn

# Start YARN
echo "****** STARTING YARN ********"
service hadoop-yarn-resourcemanager start
service hadoop-yarn-nodemanager start
service hadoop-mapreduce-historyserver start

# Create User Directories
echo "****** CREATING USER DIRECTORIES IN HDFS ********"
sudo -u hdfs hadoop fs -mkdir -p /user/vagrant
sudo -u hdfs hadoop fs -chown vagrant /user/vagrant

# Install Python Things
pip install mrjob


echo "****** RESTARTING YARN ********"
service hadoop-yarn-resourcemanager restart
service hadoop-yarn-nodemanager restart
service hadoop-mapreduce-historyserver restart


echo "****** INSTALLING SPARK ********"
apt-get install spark-core spark-master spark-worker spark-history-server spark-python