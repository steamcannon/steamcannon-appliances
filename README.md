# Boxgrinder appliance definition files for steamcannon. 

For best results, use a BoxGrinder meta-appliance to build these images.  You can
find the meta-appliances here http://www.jboss.org/boxgrinder/downloads/build/meta-appliance.html

At the moment, only the 32-bit meta-appliances can sucessfully produce these images.

Some extra items are necessary to add to a meta-appliance 
to build cirras-rpm:

**Gems necessary to use:**

* rake
    * net-ssh
    * net-sftp

**Packages necessary to install:**

* (rhq-agent)
    * java-1.6.0-openjdk-devel

* (qemu)
    * zlib-devel 
    * SDL-devel

* (cirras-management)
    * libxml2-devel
    * libxslt-devel

# How to Launch the SteamCannon AMI

As of this writing, the current AMI ID is ami-5eee1a37.  You can always find the most recent
AMI on the [BoxGrinder meta-appliance page](http://www.jboss.org/boxgrinder/downloads/build/meta-appliance.html).

# How to Build the SteamCannon AMI From Scratch

Building the SteamCannon AMI is done using the 32-bit meta-appliance AMI provided by BoxGrinder.

Open up your Amazon AWS tool of choice, provide it with the AMI ID, and launch an instance.
You will use this instance to build the SteamCannon AMI.  Once it has launched, obtain the public DNS name
and SSH to the machine (TODO: what are creds?).  In order to build the SteamCannon AMI, we'll need to add
a couple of libraries to the machine.  From the command line type:

    # yum install sqlite-devel openssl-devel libxml2 libxml2-devel libxslt libxslt-devel
    
If you want to create an EBS-backed AMI, you'll need the boxgrinder-build-ebs-delivery-plugin.  To install this,
type on the command line:

    # gem install boxgrinder-build-ebs-delivery-plugin
    
When building the SteamCannon AMI, boxgrinder will attempt to register it with Amazon AWS and provide you with an
AMI ID when it's complete.  In order to do this, you'll need to have some configuration files in place.  For EBS-backed
images, please see the configuration requirements here: http://community.jboss.org/wiki/BoxGrinderBuildPluginsDeliveryEBS
and for S3-backed images, see http://community.jboss.org/wiki/BoxGrinderBuildPluginsDeliveryS3.  For documentation
on all of the boxgrinder plugins, see http://community.jboss.org/wiki/BoxGrinderBuildPlugins.

That should take care of the build dependencies.  Building the SteamCannon appliance involves downloading a number of 
repositories, and generating RPMs, and machine image files. You could end up using a decent amount of disk space.  
The meta-appliance AMI has 2 partitions defined.  The root partition at / has 10GB of disk space which isn't quite enough, 
so when building be sure to use the 335GB partition.

    # cd /mnt/boxgrinder
    
Now you'll need to grab the latest appliance specs from github.  

    # git clone git@github.com:steamcannon/steamcannon-appliances.git
    
Once you've downloaded the git repo, all you have to do to build it is run the steamcannon:build_ami rake task.

    # cd steamcannon-appliances
    # rake steamcannon:build_ami
    
This will build a number of custom RPMs, create the machine image file, install all required RPMs, gems and other
dependencies, setup the SteamCannon database, and configure JBoss to start on boot.  Once the machine image has
been setup as above, and it will be uploaded to Amazon S3.  The last line of the rake task looks something like this:

    # I, [2010-10-20T14:43:59.519772 #9500]  INFO -- : Image successfully registered under id: ami-561aee3f.

That's your new SteamCannon image.  Fire up your favorite Amazon AWS UI and launch it.  If all goes as planned,
you should have a new Fedora 13 instance running JBoss-AS with Torquebox and SteamCannon.  Enjoy!
