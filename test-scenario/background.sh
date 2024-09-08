

sudo apt-get remove -y golang-go

sudo apt-get autoremove -y


GO_VERSION="1.23.1"

wget https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz

sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz


echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc

source ~/.bashrc


echo "go version"

