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

	*)
		echo "ERROR: Unsupported comannd $1\n"
		showHelp
		;;

	"help")
		showHelp
		;;
esac
