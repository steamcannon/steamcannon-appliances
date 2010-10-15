$: << 'lib/cantiere/lib'

require 'cantiere/helpers/rake-helper'
 
Cantiere::RakeHelper.new

namespace :steamcannon do
  desc "Build the Steamcannon AMI"
  task :build_ami => [:clean, :dependencies, :rpm_install, :create_repo] do
    sh 'boxgrinder-build appliances/steamcannon.appl -p ec2 -d ami'
  end

  desc "Clean the appliance and RPM build directories"
  task :clean do
    sh 'rm -rf build/appliances'
    sh 'rm -rf build/topdir'
  end

  desc "Install RPM build dependencies"
  task :dependencies => ['rpm:torquebox-jruby', 'rpm:steamcannon-deltacloud-core'] do
    sh 'yum install libxml2 libxml2-devel libxslt libxslt-devel'
    sh 'rpm -iF build/topdir/fedora/13/RPMS/noarch/torquebox-jruby*.rpm'
    sh 'rpm -iF build/topdir/fedora/13/RPMS/noarch/steamcannon-deltacloud-core*.rpm'
  end

  desc "Install Steamcannon RPM"
  task :rpm_install => ['rpm:steamcannon', 'rpm:torquebox-deployers'] do
    sh 'rpm -iF build/topdir/fedora/13/RPMS/noarch/torquebox-deployers*.rpm'
    sh 'rpm -iF build/topdir/fedora/13/RPMS/noarch/steamcannon-ui*.rpm'
  end

  desc "Create an RPM repo for local builds"
  task :create_repo do
    sh 'createrepo build/topdir/fedora/13/RPMS/noarch'
  end
end

