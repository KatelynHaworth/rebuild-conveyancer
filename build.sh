#!/bin/bash

function logInfo {
	echo -e "\e[92m## ${1}\e[0m"
}

function extractInitrd {
	logInfo "Extracting InitRD from build system"
	vagrant ssh -c "cp /boot/initrd.img-\$(uname -r) /data/rd_files/"
	vagrant ssh -c "cd /data/rd_files; zcat initrd.img-\$(uname -r) | cpio -i; rm initrd.img-\$(uname -r)"
}

function compileRuby {
	logInfo "Compilling Ruby 2.3 for RAM Disk"
	vagrant ssh -c "cd /tmp; wget -q https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.0.tar.gz; tar xzf ruby-2.3.0.tar.gz;"
	vagrant ssh -c "cd /tmp/ruby-2.3.0/; ./configure --prefix=/data/rd_files/usr/local"
	vagrant ssh -c "cd /tmp/ruby-2.3.0/; make; make install; cp -r ./include /data/rd_files/lib/ruby/include"
}

function installGems {
	logInfo "Installing Ohai gem"
	vagrant ssh -c "/data/rd_files/bin/gem install ohai"
}

function cleanStart {
	logInfo "## Building clean environment"
	vagrant destroy -f
	vagrant up
}

function showHelp() {
	echo "Usage: ./build.sh [COMMAND]"
	echo
	echo -e "\textract-initrd - Extracts the initrd img from the Vagrant host"
	echo -e "\tcompile-ruby - Downloads and compiles Ruby into the rd"
	echo -e "\tclean-start - Destroys and builds a new Vagrant VM"
	echo -e "\tinstall-gems - Install all required ruby gems"
	echo -e "\tall - Runs all the above tasks in order"
	echo
	exit 0
}

case $1 in
	"extract-initrd")
		extractInitrd
		;;

	"compile-ruby")
		compileRuby
		;;

	"clean-start")
		cleanStart
		;;

	"install-gems")
		installGems
		;;

	"all")
		cleanStart
		extractInitrd
		compileRuby
		installGems
		;;

	*)
		showHelp
		;;
	"help")
		showHelp
		;;
esac
