########################################################################
# Complementary shell script to provide advanced features in the box
########################################################################

echo -e "${YELLOW}------ Initiating Booster Script ------${NC}"

# Install charting libraries
pip3 install seaborn altair
# Install Flask: Barebones for serving model
# - Example code to be done
pip3 install Flask
# Install Spark support with Apache Beam
pip3 install pyspark
# Install OpenCV for image processing (preceeded by dependencies)
# https://stackoverflow.com/questions/47113029/importerror-libsm-so-6-cannot-open-shared-object-file-no-such-file-or-directo
sudo apt -y install libsm6
 pip3 install opencv-python
# Install Python ML Frameworks: MXNet
pip3 install mxnet
# Install Python ML Frameworks: pyTorch (torch and torchvision)
sed -e 's|TMPDIR=/var/tmp/||g' -i /etc/environment
sudo echo TMPDIR=/var/tmp/ >> /etc/environment
sudo pip3 install torch==1.4.0+cpu torchvision==0.5.0+cpu -f https://download.pytorch.org/whl/torch_stable.html

# Install Java
echo -e "${YELLOW}------ Install Java ------${NC}"
sudo apt --yes install openjdk-8-jre-headless

# Install Scala
echo -e "${YELLOW}------ Install Scala ------${NC}"
sudo apt -y install scala

# Install Spark
echo -e "${YELLOW}------ Install Spark ------${NC}"
# Installed with hadoop
# More info here: https://stackoverflow.com/questions/32022334/can-apache-spark-run-without-hadoop
# To speed up operations, Spark can be downloaded upfront to the
# host OS folder which is mapped to the shared folder
# /vagrant/resources/apps
cd /vagrant/resources/apps
sudo wget --no-verbose --timestamping https://archive.apache.org/dist/spark/spark-2.3.1/spark-2.3.1-bin-hadoop2.7.tgz
# Always download the checksum, overwriting any previously downloaded file
sudo wget --no-verbose --output-document=spark-2.3.1-bin-hadoop2.7.tgz.sha512 https://archive.apache.org/dist/spark/spark-2.3.1/spark-2.3.1-bin-hadoop2.7.tgz.sha512
# Compare checksum
# - Use another utility that matches the format
sudo python3 /vagrant/resources/utils/spark_sha512_gen.py
sudo  --user=ubuntu sha512sum  -c local-spark-hash.sha512

cd /home/ubuntu
sudo --user=ubuntu tar --extract --skip-old-files --file /vagrant/resources/apps/spark-2.3.1-bin-hadoop2.7.tgz
sudo --user=ubuntu ln --symbolic --force /home/ubuntu/spark-2.3.1-bin-hadoop2.7 /home/ubuntu/spark

sed -e 's|/home/ubuntu/spark/bin:||g' -e 's|PATH="\(.*\)"|PATH="/home/ubuntu/spark/bin:\1"|g' -i /etc/environment
# https://medium.com/@GalarnykMichael/install-spark-on-ubuntu-pyspark-231c45677de0
sed -e 's|SPARK_PATH=/home/ubuntu/spark||g' -i /etc/environment
sudo echo SPARK_PATH=/home/ubuntu/spark >> /etc/environment
sed -e 's|PYSPARK_DRIVER_PYTHON="jupyter"||g' -i /etc/environment
sudo echo PYSPARK_DRIVER_PYTHON="jupyter" >> /etc/environment
sed -e 's|PYSPARK_DRIVER_PYTHON_OPTS="notebook"||g' -i /etc/environment
sudo echo PYSPARK_DRIVER_PYTHON_OPTS="notebook" >> /etc/environment
sed -e 's|PYSPARK_PYTHON=python3||g' -i /etc/environment
sudo echo PYSPARK_PYTHON=python3 >> /etc/environment


# Install Zeppelin
echo -e "${YELLOW}------ Install Zeppelin ------${NC}"
# To speed up operations, Zeppelin can be downloaded upfront to the
# host OS folder which is mapped to the shared folder
# /vagrant/resources/apps
cd /vagrant/resources/apps
sudo wget --no-verbose --timestamping http://www-eu.apache.org/dist/zeppelin/zeppelin-0.8.0/zeppelin-0.8.0-bin-all.tgz
# Always download the checksum, overwriting any previously downloaded file
sudo wget --no-verbose --output-document=zeppelin-0.8.0-bin-all.tgz.sha512 https://www.apache.org/dist/zeppelin/zeppelin-0.8.0/zeppelin-0.8.0-bin-all.tgz.sha512
# Compare checksum
sudo --user=ubuntu sha512sum -c zeppelin-0.8.0-bin-all.tgz.sha512
cd /home/ubuntu
sudo --user=ubuntu tar --extract --skip-old-files --file /vagrant/resources/apps/zeppelin-0.8.0-bin-all.tgz
sudo --user=ubuntu ln --symbolic --force /home/ubuntu/zeppelin-0.8.0-bin-all /home/ubuntu/zeppelin

# Set home directory for notebook
# https://zeppelin.apache.org/docs/0.8.0/setup/operation/configuration.html
# Configs in env variable takes precedence over other configs, like in XML
sed -e 's|export ZEPPELIN_NOTEBOOK_DIR=/vagrant/znotes||g' -i /etc/environment
sudo echo export ZEPPELIN_NOTEBOOK_DIR="/vagrant/znotes" >> /etc/environment

# Set login credentails using Shiro for Zeppelin
zeppelin_shiro_file="/home/ubuntu/zeppelin/conf/shiro.ini"

# creates problem if the file exists and pass is something else etc etc
if [ -f "$zeppelin_shiro_file" ]
then
    echo "shiro.ini for Zeppelin already exists. Removing and regenerating it."
    rm -f /home/ubuntu/zeppelin/conf/shiro.ini
fi
cp /home/ubuntu/zeppelin/conf/shiro.ini.template /home/ubuntu/zeppelin/conf/shiro.ini
echo "shiro.ini created. Updating credentails now."
sed -e 's|#admin = password1, admin|admin = mlwb, admin|g' -i /home/ubuntu/zeppelin/conf/shiro.ini
sed -e 's|/api/version = anon|#/api/version = anon|g' -i /home/ubuntu/zeppelin/conf/shiro.ini

# Set fields in XML config file
# https://unix.stackexchange.com/questions/232384/argument-string-to-integer-in-bash
zeppelin_XMLconfig_file="/home/ubuntu/zeppelin/conf/zeppelin-site.xml"

# creates problem if the file exists and pass is something else etc etc
if [ -f "$zeppelin_XMLconfig_file" ]
then
    echo "XML config for Zeppelin already exists. Removing and regenerating it."
    rm -f /home/ubuntu/zeppelin/conf/zeppelin-site.xml
fi
cp /home/ubuntu/zeppelin/conf/zeppelin-site.xml.template /home/ubuntu/zeppelin/conf/zeppelin-site.xml

echo "XML config file created. Updating fields now."
key_lnum="$(grep -n zeppelin.anonymous.allowed /home/ubuntu/zeppelin/conf/zeppelin-site.xml | cut -d : -f1)"
val_lnum=$((key_lnum + 1))
sed -e "${val_lnum}s|true|false|" -i /home/ubuntu/zeppelin/conf/zeppelin-site.xml

# Start Zeppelin
/home/ubuntu/zeppelin/bin/zeppelin-daemon.sh start

# also check out:
# https://dziganto.github.io/anaconda/shiro/spark/zeppelin/zeppelinhub/How-To-Locally-Install-Apache-Spark-And-Zeppelin/

# Spark-YARN: https://www.linode.com/docs/databases/hadoop/install-configure-run-spark-on-top-of-hadoop-yarn-cluster/
# Setup hadoop: https://www.linode.com/docs/databases/hadoop/how-to-install-and-set-up-hadoop-cluster/

echo -e "${YELLOW}------ Install Hadoop ------${NC}"
echo "Nothing done currently"
# Download hadoop from http://www-eu.apache.org/dist/hadoop/common/
# sed -e 's|HADOOP_HOME=~/hadoop-2.8.0||g' -i /etc/environment
# sudo echo HADOOP_HOME=~/hadoop-2.8.0 >> /etc/environment

echo -e "${YELLOW}------ Completed Booster Script ------${NC}"