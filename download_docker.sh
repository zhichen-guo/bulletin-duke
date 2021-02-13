echo "***Installing docker using repository***"
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
echo "***Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88***"
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
echo "***Installing docker engine***"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
echo "***\nCheck that your installation was successful by running the hello-world image:\n\nsudo docker run hello-world\n***"
sudo docker run hello-world
echo "***\nVerify that you can run docker commands without 'sudo', run:\ndocker run hello-world\n***"
docker run hello-world
echo "***Installing 'compose' for linux system***"
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo "***Running post-install commands***"
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

