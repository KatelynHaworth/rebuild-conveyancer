Rebuild Conveyancer
-------------------

Rebuild Conveyancer is a simple and small linux image used by Rebuild to profile machines on their hardware and configuration, this profiled data is then stored in Rebuild's database for the use to then choose what they want to do with the newly detected machine.

This component is made up of two parts, the first one is the conveyancer service which levrages [Ohai][0] to profile the system it is running on and report back to the core, the second part is the system image which include a bare bones linux system designed to run the service on boot

Conveyancer Service
-------------------

The service is built using Scala and Akka, the service runs Ohai once loaded to collect information on the system's CPUs, storage, network settings, and more. Once the information has been collected it is formated and sent to Rebuild Core where it is stored in the database and presented to the end user as a new machine.

Conveyancer Image
-----------------

The image is a bare bones ram disk loaded by a Debian, the image contains a Java 8 runtime and a Ruby 2.2 runtime with Ohai installed. The image is built using a Debian [Vagrant][1] box to setup the file system, install the required items and then finally generate the ram disk.

TODO
----

 * Add commands to build Ruby into initrd file system: ./configure --bindir=/home/vagrant/intird/bin/ --sbindir=/home/vagrant/intird/sbin/ --sysconfdir=/home/vagrant/intird/etc/ --localstatedir=/home/vagrant/intird/var/ --libdir=/home/vagrant/intird/lib/ --prefix=/home/vagrant/intird/usr/local

 * Symlink Ruby headers to /home/vagrant/intird/lib/ruby/include

 * Install Ohai gem

Authors, Licence and Copyright
------------------------------

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

|
|:----------------|:---------------------------------------------------|
| **Author**      | Liam Haworth <liam.haworth@bluereef.com.au>        |
|                 |                                                    |
| **Copyright**   | Copyright 2016 Blue Reef Pty. Ltd.                 |
|                 |                                                    |


[0][https://github.com/chef/ohai]
[1][https://www.vagrantup.com/]
