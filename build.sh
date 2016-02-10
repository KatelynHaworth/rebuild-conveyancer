#!/bin/bash

function logInfo {
	echo -e "\e[92m## ${1}\e[0m"
}

function runCommand {
	output=`vagrant ssh -c "${1}"`

	if [ $? -ne 0 ]; then
		echo "ERROR: Command execution failed!" > /dev/stderr
		echo -e "PURPOSE:\t${2}" > /dev/stderr
		echo -e "COMMAND:\t${1}" > /dev/stderr
		echo -e "OUTPUT:\n\n${output}" > /dev/stderr
		exit 1
	fi
}

function cleanStart {
	logInfo "Building clean environment"
	vagrant destroy -f
	vagrant up
}

function prepareSource {
	logInfo "Preparing RAM disk source"
	runCommand "cp -r /data/src /tmp/src" "Copy source code to temp directory before build"
	runCommand "cd /tmp/src; sudo mknod dev/console c 5 1" "Make device node for console"
	runCommand "cd /tmp/src; sudo mknod dev/ram0 b 1 1" "Make device node for ram0"
	runCommand "cd /tmp/src; sudo mknod dev/null c 1 3" "Make device node for Null"
	runCommand "cd /tmp/src; sudo mknod dev/tty1 c 4 1" "Make device node for TTY1"
	runCommand "cd /tmp/src; sudo mknod dev/tty2 c 4 2" "Make device node for TTY2"
	runCommand "cd /tmp/src; ln -s bin sbin" "Symlink bin to sbin"
	runCommand "sudo chown vagrant:vagrant -R /tmp/src" "Change ownership on source folder to vagrant user"
}

function compileRuby {
	logInfo "Compilling Ruby 2.3 for RAM Disk"
	runCommand "cd /tmp; wget -q https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.0.tar.gz; tar xzf ruby-2.3.0.tar.gz;" "Download and extract Ruby source code"
	runCommand "cd /tmp/ruby-2.3.0/; ./configure --prefix=/tmp/src/usr/local" "Configure Ruby source code with correct build location"
	runCommand "cd /tmp/ruby-2.3.0/; make; make install; cp -r ./include /tmp/src/usr/local/lib/ruby/include" "Compile Ruby source code"
}

function installGems {
	logInfo "Installing gems"
	runCommand "/tmp/src/usr/local/bin/gem install ohai" "Install Ohai gem"
}

function buildRamDisk {
	logInfo "Building ram disk"
	runCommand "cd /tmp/src; find . | cpio -o -H newc | gzip > ../initrd.img" "Compress and create initrd"
	runCommand "cp /tmp/initrd.img /data/output/" "Copy initrd to output directory"
}

function buildISO {
	logInfo "Building Testing ISO"
	runCommand "mkdir -p /tmp/{syslinux,iso/{isolinux,kernel,images}}" "Build ISO file structure"
	runCommand "cd /tmp/syslinux; wget -q https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.zip; unzip -o -q syslinux-6.03.zip" "Download and unpack syslinux"
	runCommand "cd /tmp/iso; cp ../syslinux/bios/core/isolinux.bin ./isolinux/" "Copy ISOLinux binary into ISO file system"
	runCommand "cd /tmp/iso; cp ../syslinux/bios/com32/elflink/ldlinux/ldlinux.c32 ./isolinux/" "Copy supporting files for ISOLinux"
	runCommand "cp /data/output/initrd.img /tmp/iso/images/" "Copy initrd image onto the ISO"
	runCommand "sudo cp /data/src/boot/vmlinuz /tmp/iso/kernel/vmlinuz" "Copy linux kernel onto the ISO"
	runCommand "echo -e \"prompt 0\ndefault 1\n\nlabel 1\n    kernel /kernel/vmlinuz\n    append initrd=/images/initrd.img\" > /tmp/iso/isolinux/isolinux.cfg" "Add config for ISOLinux"
	runCommand "mkisofs -o /data/output/rebuild.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -V RebuildOS /tmp/iso" "Build ISO"
}

function showHelp() {
	echo "Usage: ./build.sh [COMMAND]"
	echo
	echo -e "\tclean-start - Destroys and builds a new Vagrant VM"
	echo -e "\tprepare-source - Copys source code to temp directory and adds device nodes"
	echo -e "\tcompile-ruby - Downloads and compiles Ruby"
	echo -e "\tinstall-gems - Install all required ruby gems"
	echo -e "\tbuild-ram-disk - Builds the initrd.img file from the source code"
	echo -e "\tall - Runs all the above tasks in order"
	echo
	echo "Optional Commands:"
        echo -e "\tbuild-iso - Builds an ISO for testing the initrd (See testing)"
	echo
	exit 0
}

case $1 in
	"clean-start")
		cleanStart
		;;

	"prepare-source")
		prepareSource
		;;

	"compile-ruby")
		compileRuby
		;;

	"install-gems")
		installGems
		;;

	"build-ram-disk")
		buildRamDisk
		;;

	"all")
		cleanStart
		prepareSource
		compileRuby
		installGems
		buildRamDisk
		;;

	"build-iso")
		buildISO
		;;

	*)
		echo "ERROR: Unsupported comannd $1\n"
		showHelp
		;;

	"help")
		showHelp
		;;
esac
