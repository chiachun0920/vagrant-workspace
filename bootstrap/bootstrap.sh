# env=debug
name=chris
email=chiachun0920@gmail.com

_install_nvm () {
  echo "download installing script"
  sudo curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
  source ~/.bashrc
  pushd /home/$USER/.nvm
  source nvm.sh
  nvm install node
  nvm use node
  popd
  npm install -g yarn
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
  
  sudo groupadd docker
  sudo gpasswd -a $USER docker

  sudo curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose

  base=https://github.com/docker/machine/releases/download/v0.16.0 &&
  sudo curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
  sudo install /tmp/docker-machine /usr/local/bin/docker-machine
}

_install () {
  echo "[x] Start to install $1 ($((total-$#+1))/$total)"
  _install_$1
  shift 1
  if [ $# -ne 0 ]; then
    _install $@
  fi
}

_setup_git () {
  git config --global user.email "$email"
  git config --global user.name "$name"
  git config --global alias.lg "log --oneline --decorate --graph --all"
}

_setup_alias () {
  alias_dps="alias dps='docker ps --format \"table {{.Names}}\t{{.ID}}\t{{.Ports}}\"'"
  echo $alias_dps >> ~/.bashrc
}

_install_Vundle() {
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  vimrcSrc=https://raw.githubusercontent.com/chiachun0920/vagrant-workspace/master/.vimrc
  curl $vimrcSrc -o ~/.vimrc
  vim +PluginInstall +qall
}

_install_YCM_dependencies() {
  sudo apt-get install build-essential cmake python3-dev python-dev -y
  cd ~/.vim/bundle/YouCompleteMe
  ./install.py --ts-completer
  cd ~/.vim/bundle/YouCompleteMe/third_party/ycmd
  npm install -g --prefix third_party/tsserver typescript
}

_install_ack_dependencies() {
  sudo apt-get install ack-grep -y
  ackrcSrc=https://raw.githubusercontent.com/chiachun0920/vagrant-workspace/master/.ackrc
  curl $ackrcSrc -o ~/.ackrc
}

_setup_vim () {
  _install_Vundle
  _install_YCM_dependencies
  _install_ack_dependencies
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
setup alias git vim

sudo apt-get install htop

echo "cd /workspace/" >> ~/.bashrc
