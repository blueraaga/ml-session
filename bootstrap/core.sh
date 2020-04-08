########################################################################
# Core shell script to set up the box with all the critical/minimal
# requirements
########################################################################

# Colors to use
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
NC="\033[0m"

echo -e "${GREEN}------------------------${NC}"
echo -e "${GREEN}Start Shell Script${NC}"
echo -e "${GREEN}------------------------${NC}"

echo -e "${YELLOW}------ Initiating Core Script ------${NC}"

echo -e "${YELLOW}------ Export language related env. vaiables ------${NC}"
# Take care of language related notification on ssh login in
# Ubuntu 16.04
# https://stackoverflow.com/questions/26263249/how-to-modify-etc-environment-from-a-bash-script
sed -e 's|LC_ALL=C.UTF-8||g' -i /etc/environment
sudo echo LC_ALL=C.UTF-8 >> /etc/environment
sed -e 's|LANG=C.UTF-8||g' -i /etc/environment
sudo echo LANG=C.UTF-8 >> /etc/environment

echo -e "${YELLOW}------ Update and upgrade package list ------${NC}"
# Update and upgrade all packages
sudo apt update
sudo apt -y upgrade

# Install pip, upgrade it (leading to 2 pips - system and python) and
# then remove system pip. Final version is pip 10.
echo -e "${YELLOW}------ Install Python pip ------${NC}"
sudo apt install -y python3-pip

echo -e "${YELLOW}------ Upgrade Python pip ------${NC}"
pip3 install --upgrade pip

# echo -e "${RED}------ Remove pip system package ------${NC}"
# sudo apt-get -y remove python3-pip

# Install Python packages
echo -e "${YELLOW}------ Install Python packages ------${NC}"
# - Explore possibility for requirements.txt
# Install math processing stuffs
pip3 install numpy scipy pandas
# Install charting libraries
pip3 install matplotlib
# Install jupyter and its plugins
pip3 install jupyter
# Install Python ML Frameworks: Scikit-learn, TensorFlow
pip3 install scikit-learn
pip3 install tensorflow keras
# Install VirtualEnv
pip3 install virtualenv

# Start Jupyter notebook
echo -e "${YELLOW}------ Start Jupyter notebook ------${NC}"
# - Explore running Jupyter as a service
echo y | jupyter notebook --generate-config
echo -e 'mlwb\nmlwb' | jupyter notebook password
sudo jupyter notebook --ip=0.0.0.0 --port=8888 --allow-root --notebook-dir='/vagrant/jnotes' &

echo -e "${YELLOW}------ Clean /etc/environment ------${NC}"
# Delete empty lines in /etc/environment
sed -e '/^\s*$/d' -i /etc/environment

echo -e "${YELLOW}------ Completed Core Script ------${NC}"
