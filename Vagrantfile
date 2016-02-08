# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty32"

  config.vm.synced_folder "cd_root", "/data/cd_root"
  config.vm.synced_folder "rd_files", "/data/rd_files"
  config.vm.synced_folder "output", "/data/output"

  config.vm.provision "shell", inline: <<-SHELL
    echo "###### INSTALLING 3RD PARTY TOOLS"
    sudo apt-get -qq update
    sudo apt-get -qq install unzip genisoimage genometools -y
    
    echo "###### DOWNLOADING SYSLINUX"
    mkdir /tmp/syslinux
    cd /tmp/syslinux
    wget -q https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.zip 
    unzip -q syslinux-6.03.zip
    
    echo "###### BUILDING ISO FILESYSTEM"
    mkdir /data/cd_root/{isolinux,images}
    cp bios/core/isolinux.bin /data/cd_root/isolinux/
    cp bios/com32/elflink/ldlinux/ldlinux.c32 /data/cd_root/isolinux/

    echo "###### BUILDING INITRD"
    cd /data/rd_files
    find . | cpio -o -H newc | gzip - > /data/cd_root/images/initrd.img

    echo "###### MAKING ISO"
    cd
    mkisofs -o /data/output/rebuild.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -V RebuildOS /data/cd_root
  SHELL
end
