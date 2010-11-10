
##
## Appliances
##

# -- VMware
desc 'Build the SteamCannon front end agaent for VMware including all required RPMs.'
task 'platform:frontend:vmware' => [ 'platform:frontend:rpm', 'platform:frontend:vmware:grind' ]
desc 'Refreshes the local RPM repository data and builds the SteamCannon front end agent for VMWare. Does NOT rebuild RPMs'
task 'platform:frontend:vmware:grind' => 'rpm:repodata:force' do
  sh "boxgrinder-build -W ./appliances/postgresql.appl -p vmware"
end

desc 'Build the SteamCannon app server agent for VMware including all required RPMs.'
task 'platform:appserver:vmware' => [ 'platform:appserver:rpm', 'platform:appserver:vmware:grind' ] 
desc 'Refreshes the local RPM repository data and builds the SteamCannon app server agent for VMware. Does NOT rebuild RPMs'
task 'platform:appserver:vmware:grind' => 'rpm:repodata:force' do
  sh "boxgrinder-build -W ./appliances/appserver.appl -p vmware"
end

desc 'Build the SteamCannon postgresql agent for VMware including all required RPMs.'
task 'platform:postgresql:vmware' => [ 'platform:postgresql:rpm', 'platform:postgresql:vmware:grind' ]
desc 'Refreshes the local RPM repository data and builds the SteamCannon postgresql agent for VMware. Does NOT rebuild RPMs'
task 'platform:postgresql:vmware:grind' => 'rpm:repodata:force' do
  sh "boxgrinder-build -W ./appliances/postgresql.appl -p vmware"
end

desc 'Build the SteamCannon developer standalone agent for VMware including all required RPMs.'
task 'platform:developer-standalone:vmware' => [ 'platform:developer-standalone:rpm', 'platform:developer-standalone:vmware:grind' ]
desc 'Refreshes the local RPM repository data and builds the SteamCannon developer standalone agent for VMware. Does NOT rebuild RPMs'
task 'platform:developer-standalone:vmware:grind' => 'rpm:repodata:force' do
  sh "boxgrinder-build -W ./appliances/developer-standalone.appl -p vmware"
end

desc 'Build the SteamCannon Meta-Appliance for VMware'
task 'platform:meta:vmware' do
  begin
    interrupt_handler = proc{ restore_local_delivery }
    trap "SIGINT", interrupt_handler
    scribble_config('local', {'path'=>'./vmware'})
    sh "boxgrinder-build -W ./appliances/steamcannon-meta.appl -p vmware -d local"
  ensure
    restore_config('local')
  end
end

# -- EC2

desc 'Build the SteamCannon front end agent AMI for EC2 including all required RPMs.'
task 'platform:frontend:ec2' => [ 'platform:frontend:rpm', 'platform:frontend:ec2:grind' ]
desc 'Refreshes the local RPM repository data and builds the SteamCannon front end agent AMI for EC2. Does NOT rebuild RPMs'
task 'platform:frontend:ec2:grind' => 'rpm:repodata:force' do
  sh "boxgrinder-build -W ./appliances/frontend.appl -p ec2 -d ami"
end

desc 'Build the SteamCannon app server agent AMI for EC2 including all required RPMs.'
task 'platform:appserver:ec2' => [ 'platform:appserver:rpm', 'platform:appserver:ec2:grind' ] 
desc 'Refreshes the local RPM repository data and builds the SteamCannon app server agent AMI for EC2. Does NOT rebuild RPMs'
task 'platform:appserver:ec2:grind' => 'rpm:repodata:force' do
  sh "boxgrinder-build -W ./appliances/appserver.appl -p ec2 -d ami"
end

desc 'Build the SteamCannon postgresql agent AMI for EC2 including all required RPMs.'
task 'platform:postgresql:ec2' => [ 'platform:postgresql:rpm', 'platform:postgresql:ec2:grind' ]
desc 'Refreshes the local RPM repository data and builds the SteamCannon postgresql server agent AMI for EC2. Does NOT rebuild RPMs'
task 'platform:postgresql:ec2:grind' => 'rpm:repodata:force' do
  sh "boxgrinder-build -W ./appliances/postgresql.appl -p ec2 -d ami"
end

desc 'Build the SteamCannon developer standalone agent AMI for EC2 including all required RPMs.'
task 'platform:developer-standalone:ec2' => [ 'platform:developer-standalone:rpm', 'platform:developer-standalone:ec2:grind' ]
desc 'Refreshes the local RPM repository data and builds the SteamCannon developer-standalone server agent AMI for EC2. Does NOT rebuild RPMs'
task 'platform:developer-standalone:ec2:grind' => 'rpm:repodata:force' do
  sh "boxgrinder-build -W ./appliances/developer-standalone.appl -p ec2 -d ami"
end

desc 'Build the SteamCannon Meta-Appliance for EC2 as an EBS-backed AMI'
task 'platform:meta:ec2' do
  sh "boxgrinder-build -W ./appliances/steamcannon-meta.appl -p ec2 -d ebs"
end



###
### RPM
###

desc 'Build all RPMs for the front-end appliance'
task 'platform:frontend:rpm' => [
  'platform:rpm:steamcannon-agent',
  'rpm:mod_cluster',
]

desc 'Build all PRMs for the appserver appliance'
task 'platform:appserver:rpm' => [
  'platform:rpm:steamcannon-agent',
  'rpm:jboss-as6',
  'rpm:jboss-as6-cloud-profiles',
  'rpm:torquebox-deployers',
  'rpm:torquebox-cloud-profiles-deployers',
  'platform:deps:torquebox:rpm',
] 

desc 'Build all RPMs for the postgresql appliance'
task 'platform:postgresql:rpm' => [
  'platform:rpm:steamcannon-agent',
]

desc 'Build all RPMs for the developer standalone appliance'
task 'platform:developer-standalone:rpm' => [
  'platform:appserver:rpm',
  'platform:postgresql:rpm',
  'rpm:jboss-as6-developer',
  'rpm:jboss-as6-cloud-profiles-developer',
]

desc 'Build all RPMs for torquebox. Requires git://github.com/torquebox/torquebox-rpm.git in the parent directory.'
task 'platform:deps:torquebox:rpm' do
  Dir.chdir( '../torquebox-rpm' ) do
    sh 'rake rpm:all'
    sh 'rake rpm:repodata:force'
  end
end

desc 'Determines dependencies for steamcannon-agent and writes RPM spec files'
task 'platform:rumpler:steamcannon-agent' => [ 'dist:sanity:versions:steamcannon-agent:verify' ] do
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
task 'platform:rpm:steamcannon-agent' => [
  'platform:rpm:steamcannon-agent:deps',
  'rpm:steamcannon-agent'
]

desc 'Create all required RPMs for steamcannon-agent'
task 'platform:rpm:steamcannon-agent:deps' => 'platform:rumpler:steamcannon-agent' do
  Dir.chdir( '../steamcannon-agent-rpm' ) do
    sh 'rake rpm:all'
    sh 'rake rpm:repodata:force'
  end
end

desc 'Clean out steamcannon-agent RPM specs'
task 'platform:rumpler:steamcannon-agent:clean' do 
  sh 'rm -Rf ../steamcannon-agent-rpm/specs' 
end

desc 'Clean steamcannon-agent RPM builds'
task 'dist:rpm:steamcannon-agent:clean' do
  sh 'rm -Rf ../steamcannon-agent-rpm/build/topdir' 
end

