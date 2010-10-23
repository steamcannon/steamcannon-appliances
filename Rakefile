$: << 'lib/cantiere/lib'

require 'cantiere/helpers/rake-helper'
 
Cantiere::RakeHelper.new

steamcannon_version = nil
torquebox_version   = nil
deltacloud_version  = '0.0.8.1'

torquebox_rpm_version = '1.0.0.Beta23.SNAPSHOT'

namespace :steamcannon do
  desc "Build the Steamcannon AMI"
  task :build_ami => [:clean, :dependencies, :rpm_install, :create_repo] do
    sh 'boxgrinder-build -W appliances/steamcannon.appl -p ec2 -d ebs'
  end

  desc "Clean the appliance and RPM build directories"
  task :clean do
    sh 'rm -rf build/appliances'
    sh 'rm -rf build/topdir'
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

  task :appliance=>[
    'steamcannon:appliance:sanity-check',
    'steamcannon:appliance:verify-versions',
    'steamcannon:appliance:rumpler',
  ]

  namespace :appliance do 

    task 'vmware' => 'steamcannon:appliance:rpm' do
      sh "sudo boxgrinder-build -W ./appliances/steamcannon.appl -p vmware"
    end

    task 'vmware:clean' do
      sh "sudo rm -Rf ./build/appliances/i686/fedora/13/steamcannon/vmware-plugin"
    end

    task 'sanity-check'=>[ 'sanity-check-dirs', 'sanity-check-versions' ] 

    task 'sanity-check-dirs' do
      [ 
        '../rumpler',
        '../torquebox-rpm',
        '../steamcannon-rpm',
        '../deltacloud-rpm',
        '../steamcannon',
      ].each do |dir|
        print "Checking #{dir}...."
        if ( File.exist?( dir ) )
          puts "kk!"
        else
          fail( "Missing important directory: #{dir}" )
        end
      end
    end

    task 'sanity-check-versions' do
      torquebox_versions = {}
      [ 
        './specs/torquebox-deployers.spec',
        './specs/torquebox-cloud-profiles-deployers.spec',
        '../torquebox-rpm/specs/torquebox-rubygems.spec',
      ].each do |spec|
        torquebox_versions[spec] = determine_value( spec, 'torquebox_build_number' )
      end
      if ( torquebox_versions.values.uniq.size == 1 )
        torquebox_version = torquebox_versions.values.uniq.first
      else
        puts "TorqueBox build number mismatch!"
        torquebox_versions.each do |spec, ver|
          puts "  #{ver} - #{spec}"
        end
        fail( "TorqueBox build number mismatch" )
      end
      steamcannon_version = determine_value( './specs/steamcannon.spec', 'steamcannon_version' )
    end

    task 'verify-versions' => [ 'sanity-check-versions' ] do
      puts "TorqueBox build number...#{torquebox_version}"
      puts "SteamCannon version......#{steamcannon_version}"
      print "Type 'y' if these versions are acceptable: "
      c = STDIN.gets.strip
      if ( c.downcase != 'y' )
        fail "You didn't type 'y'"
      end
    end

    task 'clean' do
    
      sh 'rm -Rf ../torquebox-rpm/build/*' 
      sh 'rm -Rf ../torquebox-rpm/specs/gems/*'

      sh 'rm -Rf ../steamcannon-rpm/specs/*' 
      sh 'rm -Rf ../steamcannon-rpm/build/*' 

      sh 'rm -Rf ../deltacloud-rpm/specs/*'
      sh 'rm -Rf ../deltacloud-rpm/build/*'

    end

    task 'rumpler'=>[ 'rumpler-torquebox', 'rumpler-deltacloud', 'rumpler-steamcannon' ]
    task 'rpm'=>[ 
      'rumpler', 
      'rpm-torquebox', 
      'rpm-deltacloud', 
      'rpm-steamcannon', 
      'rpm:jboss-as6',
      'rpm:torquebox-deployers',
      'rpm:steamcannon-deltacloud-core-deployment',
      'rpm:repodata:force',
    ]

    task 'rumpler-torquebox' => [ 'verify-versions' ] do
      puts "rumpling torquebox-rpm"
      Dir.chdir( "../torquebox-rpm" ) do
        FileUtils.mkdir_p( 'specs/gems' )
        sh "../rumpler/bin/rumpler -r gemfiles/root.yml -o ./specs/gems/ -n torquebox-rubygems-dependencies -V #{torquebox_rpm_version}"
      end
    end

    task 'rumpler-deltacloud' => [ 'verify-versions' ] do
      puts "rumpling deltacloud-rpm"
      Dir.chdir( "../deltacloud-rpm" ) do
        FileUtils.mkdir_p( 'specs' )
        sh "../rumpler/bin/rumpler -g steamcannon-deltacloud-core -v #{deltacloud_version} -o specs -r ../torquebox-rpm/gemfiles/root.yml"
      end
    end

    task 'rumpler-steamcannon' => [ 'verify-versions' ] do
      puts "rumpling steamcannon-rpm"
      Dir.chdir( "../steamcannon" ) do
        sh "git fetch origin"
        sh "git checkout -f #{steamcannon_version}"
        FileUtils.mkdir_p( '../steamcannon-rpm/specs' )
        sh "../rumpler/bin/rumpler -a -v #{steamcannon_version} -o ../steamcannon-rpm/specs -r ../torquebox-rpm/gemfiles/root.yml"
      end
    end

    task 'rpm-torquebox' do
      Dir.chdir( '../torquebox-rpm' ) do
        sh 'rake rpm:all'
        sh 'rake rpm:repodata:force'
      end
    end

    task 'rpm-deltacloud' do
      Dir.chdir( '../deltacloud-rpm' ) do
        sh 'rake rpm:all'
        sh 'rake rpm:repodata:force'
      end
    end

    task 'rpm-steamcannon' do
      Dir.chdir( '../steamcannon-rpm' ) do
        sh 'rake rpm:all'
        sh 'rake rpm:repodata:force'
      end
    end

  end
end

def determine_value(file_path, key)
  File.open( file_path ) do |f|
    f.each_line do |line|
      if ( line =~ %r(^\s*%define\s*#{key}\s*([^\s]+)) )
        return $1
      end
    end
  end
  nil
end
