PLATFORM_APPLIANCES = ['frontend', 'appserver', 'postgresql', 'developer-standalone']

namespace :platform do
  ##
  ## Appliances
  ##

  # -- VMware
  desc 'Build all the SteamCannon appliances[frontend, appserver, postgresql and developer-standalone], plus all of their dependencies, for vmware'
  task 'appliances:vmware' do
    puts "Not implemented yet. Complain to Lance"
  end

  desc 'Build the SteamCannon front end agaent for VMware including all required RPMs.'
  task 'frontend:vmware' => [ 'frontend:rpm', 'frontend:vmware:grind' ]

  desc 'Refreshes the local RPM repository data and builds the SteamCannon front end agent for VMWare. Does NOT rebuild RPMs'
  task 'frontend:vmware:grind' => 'rpm:repodata:force' do
    boxgrinder_build :appliance => :frontend, :platform => :vmware
  end

  desc 'Build the SteamCannon app server agent for VMware including all required RPMs.'
  task 'appserver:vmware' => [ 'appserver:rpm', 'appserver:vmware:grind' ]

  desc 'Refreshes the local RPM repository data and builds the SteamCannon app server agent for VMware. Does NOT rebuild RPMs'
  task 'appserver:vmware:grind' => 'rpm:repodata:force' do
    boxgrinder_build :appliance => :appserver, :platform => :vmware
  end

  desc 'Build the SteamCannon postgresql agent for VMware including all required RPMs.'
  task 'postgresql:vmware' => [ 'postgresql:rpm', 'postgresql:vmware:grind' ]

  desc 'Refreshes the local RPM repository data and builds the SteamCannon postgresql agent for VMware. Does NOT rebuild RPMs'
  task 'postgresql:vmware:grind' => 'rpm:repodata:force' do
    boxgrinder_build :appliance => :postgresql, :platform => :vmware
  end

  desc 'Build the SteamCannon developer standalone agent for VMware including all required RPMs.'
  task 'developer-standalone:vmware' => [ 'developer-standalone:rpm', 'developer-standalone:vmware:grind' ]

  desc 'Refreshes the local RPM repository data and builds the SteamCannon developer standalone agent for VMware. Does NOT rebuild RPMs'
  task 'developer-standalone:vmware:grind' => 'rpm:repodata:force' do
    boxgrinder_build :appliance => :developer-standalone, :platform => :vmware
  end

  desc 'Build the SteamCannon Meta-Appliance for VMware'
  task 'meta:vmware' do
    begin
      #FIXME: this should be switched to use the command line config
      #feature for BG
      interrupt_handler = proc{ restore_local_delivery }
      trap "SIGINT", interrupt_handler
      scribble_config('local', {'path'=>'./vmware'})
      boxgrinder_build :appliance => :steamcannon-meta, :platform => :vmware, :delivery => :local
    ensure
      restore_config('local')
    end
  end

  # -- EC2
  desc 'Build all the SteamCannon appliances [frontend, appserver, postgresql and developer-standalone], plus all of their dependencies, for vmware'
  task 'all:ec2' => [
                     'all:rpm', 'all:ec2'
                    ]

  desc 'Build all the SteamCannon appliances [frontend, appserver, postgresql, and developer-standalone]'
  task 'appliances:ec2' => [
                            'frontend:ec2', 'appserver:ec2', 'postgresql:ec2', 'developer-standalone:ec2'
                           ]

  PLATFORM_APPLIANCES.each do |appl|
    desc "Build the #{appl} appliance in all regions"
    task "#{appl}:ec2:all_regions" do
      abort 'You must set BUCKET_PREFIX' unless ENV['BUCKET_PREFIX']
      regions = %w{ us-east-1 us-west-1 ap-southeast-1 } # eu-west-1 support is waiting for a euca-upload-bundle fix
      ENV['REGION'] = regions.shift
      #build in the first region - this will build all the required rpms
      Rake::Task["platform:#{appl}:ec2"].invoke
      sh "mv log/boxgrinder.log log/boxgrinder-#{ENV['REGION']}.log"
      regions.each do |region|
        ENV['REGION'] = region
        #clear the built image so we can bundle another region
        sh "find build -name s3-plugin | xargs rm -rf"
        boxgrinder_build :appliance => appl, :platform => :ec2, :delivery => :ami
        sh "mv log/boxgrinder.log log/boxgrinder-#{region}.log"
      end
      puts '=' * 60
      sh "grep -h 'registered under' log/boxgrinder-*.log"
      puts '=' * 60
    end
  end
  
  desc 'Build the SteamCannon front end agent AMI for EC2 including all required RPMs.'
  task 'frontend:ec2' => [ 'frontend:rpm', 'frontend:ec2:grind' ]

  desc 'Refreshes the local RPM repository data and builds the SteamCannon front end agent AMI for EC2. Does NOT rebuild RPMs'
  task 'frontend:ec2:grind' => 'rpm:repodata:force' do
    boxgrinder_build :appliance => :frontend, :platform => :ec2, :delivery => :ami
  end

  desc 'Build the SteamCannon app server agent AMI for EC2 including all required RPMs.'
  task 'appserver:ec2' => [ 'appserver:rpm', 'appserver:ec2:grind' ]

  desc 'Refreshes the local RPM repository data and builds the SteamCannon app server agent AMI for EC2. Does NOT rebuild RPMs'
  task 'appserver:ec2:grind' => 'rpm:repodata:force' do
    boxgrinder_build :appliance => :appserver, :platform => :ec2, :delivery => :ami
  end

  desc 'Build the SteamCannon postgresql agent AMI for EC2 including all required RPMs.'
  task 'postgresql:ec2' => [ 'postgresql:rpm', 'postgresql:ec2:grind' ]

  desc 'Refreshes the local RPM repository data and builds the SteamCannon postgresql server agent AMI for EC2. Does NOT rebuild RPMs'
  task 'postgresql:ec2:grind' => 'rpm:repodata:force' do
    boxgrinder_build :appliance => :postgresql, :platform => :ec2, :delivery => :ami
  end

  desc 'Build the SteamCannon developer standalone agent AMI for EC2 including all required RPMs.'
  task 'developer-standalone:ec2' => [ 'developer-standalone:rpm', 'developer-standalone:ec2:grind' ]

  desc 'Refreshes the local RPM repository data and builds the SteamCannon developer-standalone server agent AMI for EC2. Does NOT rebuild RPMs'
  task 'developer-standalone:ec2:grind' => 'rpm:repodata:force' do
    boxgrinder_build :appliance => :"developer-standalone", :platform => :ec2, :delivery => :ami
  end

  desc 'Build the SteamCannon Meta-Appliance for EC2 as an EBS-backed AMI'
  task 'meta:ec2' do
    boxgrinder_build :appliance => :"steamcannon-meta", :platform => :ec2, :delivery => :ebs
  end



  ###
  ### RPM
  ###
  desc 'Build all required RPMs for all platform appliances'
  task 'all:rpm' => [
                     'frontend:rpm', 'appserver:rpm', 'postgresql:rpm', 'developer-standalone:rpm'
                    ]

  desc 'Build all RPMs for the front-end appliance'
  task 'frontend:rpm' => [
                          'rpm:steamcannon-agent:build',
                          'rpm:mod_cluster',
                         ]

  desc 'Build all RPMs for the appserver appliance'
  task 'appserver:rpm' => [
                           'dist:rpm:torquebox',
                           'rpm:steamcannon-agent:build',
                           'rpm:jboss-as6',
                           'rpm:jboss-as6-cloud-profiles',
                           'rpm:torquebox-deployers',
                           'rpm:torquebox-cloud-profiles-deployers',
                           'deps:torquebox:rpm',
                          ]

  desc 'Build all RPMs for the postgresql appliance'
  task 'postgresql:rpm' => [
                            'rpm:steamcannon-agent:build',
                           ]

  desc 'Build all RPMs for the developer standalone appliance'
  task 'developer-standalone:rpm' => [
                                      'appserver:rpm',
                                      'postgresql:rpm',
                                      'rpm:jboss-as6-developer',
                                      'rpm:jboss-as6-cloud-profiles-developer',
                                     ]

  desc 'Build all RPMs for torquebox. Requires git://github.com/torquebox/torquebox-rpm.git in the parent directory.'
  task 'deps:torquebox:rpm' do
    Dir.chdir( '../torquebox-rpm' ) do
      sh 'rake rpm:all'
      sh 'rake rpm:repodata:force'
    end
  end

  desc 'Determines dependencies for steamcannon-agent and writes RPM spec files'
  task 'rumpler:steamcannon-agent' => [ 'dist:sanity:versions:steamcannon-agent:verify' ] do
    puts "rumpling steamcannon-agent-rpm"
    Dir.chdir( "../steamcannon-agent" ) do
      sh "git fetch origin"
      sh "git checkout -f #{BuildVersion.instance.steamcannon_agent}"
      FileUtils.mkdir_p( '../steamcannon-agent-rpm/specs' )
      if ( Dir[ '../steamcannon-agent-rpm/specs/*.spec' ].empty? )
        config_file = File.join( '..', 'steamcannon-agent', 'config', 'rumpler.yaml' )
        sh "../rumpler/bin/rumpler -a -v #{BuildVersion.instance.steamcannon_agent} -o ../steamcannon-agent-rpm/specs -c #{config_file}"
      else
        puts "INFO: specs present, not rumpling"
      end
    end
  end

  desc 'Create all required RPMs for steamcannon-agent'
  task 'rpm:steamcannon-agent:build' => [
                                   'rpm:steamcannon-agent:deps',
                                   'rpm:steamcannon-agent'
                                  ]

  desc 'Create all required RPMs for steamcannon-agent'
  task 'rpm:steamcannon-agent:deps' => 'rumpler:steamcannon-agent' do
    Dir.chdir( '../steamcannon-agent-rpm' ) do
      sh 'rake rpm:all'
      sh 'rake rpm:repodata:force'
    end
  end

  desc 'Clean out steamcannon-agent RPM specs'
  task 'rumpler:steamcannon-agent:clean' do
    sh 'rm -Rf ../steamcannon-agent-rpm/specs'
  end

  desc 'Clean steamcannon-agent RPM builds'
  task 'rpm:steamcannon-agent:clean' do
    sh 'rm -Rf ../steamcannon-agent-rpm/build/topdir'
  end

end
