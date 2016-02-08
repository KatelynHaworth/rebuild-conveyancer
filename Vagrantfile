# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty32"

  config.vm.synced_folder "cd_root", "/data/cd_root"
  config.vm.synced_folder "rd_files", "/data/rd_files"
  config.vm.synced_folder "output", "/data/output"
  config.vm.synced_folder "defines", "/data/defines"

  config.vm.provision "shell", inline: <<-SHELL
    sudo locale-gen en_AU.UTF-8
    echo "nameserver 8.8.8.8" > /etc/resolv.conf 

    echo "###### INSTALLING 3RD PARTY TOOLS"
    sudo apt-get -qq update
    sudo apt-get -qq install unzip genisoimage genometools zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev libyajl2 build-essential -y
    
    echo "###### DOWNLOADING SYSLINUX"
    mkdir -p /tmp/syslinux
    cd /tmp/syslinux
    wget -q https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.zip 
    unzip -q syslinux-6.03.zip
    
    echo "###### BUILDING ISO FILESYSTEM AND ADDING ISOLINUX"
    mkdir -p /data/cd_root/{isolinux,images}
    cp bios/core/isolinux.bin /data/cd_root/isolinux/
    cp bios/com32/elflink/ldlinux/ldlinux.c32 /data/cd_root/isolinux/

    echo "###### ENVIRONMENT READY"
  SHELL
end
