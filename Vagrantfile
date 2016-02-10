# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty32"

  config.vm.synced_folder "src", "/data/src"
  config.vm.synced_folder "output", "/data/output"

  config.vm.provision "shell", inline: <<-SHELL
    sudo locale-gen en_AU.UTF-8
    echo "nameserver 8.8.8.8" > /etc/resolv.conf 
    sudo apt-get -qq update
    sudo apt-get -qq install unzip genisoimage genometools zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev libyajl2 build-essential -y
  SHELL
end
