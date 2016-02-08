function logInfo() {
	echo -e "\e[92m## ${1}\e[0m"
}

function extractInitrd() {
	logInfo "Extracting InitRD from build system"
	vagrant ssh -c "cp /boot/initrd.$$(uname -r) /data/rd_files/"
	vagrant ssh -c "cd /data/rd_files; zcat initrd.$$(uname -r) | cpio -i; rm initrd.$$(uname -r)"
}

function compileRuby() {
	logInfo "## Compilling Ruby 2.3 for RAM Disk"
	vagrant ssh -c "cd /tmp; wget -q https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.0.tar.gz; tar xzf ruby-2.3.0.tar.gz;"
	vagrant ssh -c "cd /tmp/ruby-2.3.0/; ./configure --bindir=/data/rd_files/bin/ --sbindir=/data/rd_files/sbin/ --sysconfdir=/data/rd_files/etc/ --localstatedir=/data/rd_files/var/ --libdir=/data/rd_files/lib/ --prefix=/data/rd_files/usr/local"
	vagrant ssh -c "cd /tmp/ruby-2.3.0/; make; make install; cp -r ./include /data/rd_riles/lib/ruby/include"
}

function cleanStart() {
	logInfo "## Building clean environment"
	vagrant destroy -f
	vagrant up
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

	"all")
		cleanStart
		extractInitrd
		compileRuby
		;;
esac
