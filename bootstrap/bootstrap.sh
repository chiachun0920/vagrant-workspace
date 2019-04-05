# env=debug

_install_nvm () {
	echo "download installing script"
	sudo curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
	source ~/.bashrc
	pushd /home/vagrant/.nvm
	source nvm.sh
	nvm install node
	nvm use node
	popd
}

_install_docker () {
	echo "SET UP THE DOCKER REPOSITORY"
	echo "Update the apt package index"
	sudo apt-get update -y
	echo "Install packages to allow apt to use a repository over HTTPS"
	sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
	echo "Add Docker’s official GPG key"
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	echo "add-apt-repository"
	sudo add-apt-repository \
			"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
			$(lsb_release -cs) \
			stable" -y
	echo "INSTALL DOCKER CE"
	sudo apt-get update -y
	sudo apt-get install docker-ce docker-ce-cli containerd.io -y
	sudo docker run hello-world
}

_install () {
	echo "[x] Start to install $1 ($((total-$#+1))/$total)"
	_install_$1
	shift 1
	if [ $# -ne 0 ]; then
		_install $@
	fi
}

_setup_alias () {
	alias_dps="alias dps='docker ps --format \"talbe {{.Names}}\t{{.ID}}\t{{.Ports}}\"'"
	echo $alias_dps >> ~/.bashrc
}

_setup () {
	_setup_$1
	shift 1
	if [ $# -ne 0 ]; then
		_setup $@
	fi
}

install () {
	total=$#
	_install $@
}

setup () {
	_setup $@
}

echo "SETUP DEV DEPENDENCIES"

# install development dependencies
install nvm docker
setup alias
