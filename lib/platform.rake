
##
## Appliances
##

# -- VMware
desc 'Build the SteamCannon front end agaent for VMware including all required RPMs.'
task 'platform:frontend:vmware' => [ 'platform:frontend:rpm', 'platform:frontend:vmware:grind' ]
desc 'Refreshes the local RPM repository data and builds the SteamCannon front end agent for VMWare. Does NOT rebuild RPMs'
task 'platform:frontend:vmware:grind' => 'rpm:repodata:force' do
  sh "sudo boxgrinder-build -W ./appliances/postgresql.appl -p vmware"
end

desc 'Build the SteamCannon app server agent for VMware including all required RPMs.'
task 'platform:appserver:vmware' => [ 'platform:appserver:rpm', 'platform:appserver:vmware:grind' ] 
desc 'Refreshes the local RPM repository data and builds the SteamCannon app server agent for VMware. Does NOT rebuild RPMs'
task 'platform:appserver:vmware:grind' => 'rpm:repodata:force' do
  sh "sudo boxgrinder-build -W ./appliances/appserver.appl -p vmware"
end

desc 'Build the SteamCannon postgresql agent for VMware including all required RPMs.'
task 'platform:postgresql:vmware' => [ 'platform:postgresql:rpm', 'platform:postgresql:vmware:grind' ]
desc 'Refreshes the local RPM repository data and builds the SteamCannon postgresql agent for VMware. Does NOT rebuild RPMs'
task 'platform:postgresql:vmware:grind' => 'rpm:repodata:force' do
  sh "sudo boxgrinder-build -W ./appliances/postgresql.appl -p vmware"
end

desc 'Build the SteamCannon developer standalone agent for VMware including all required RPMs.'
task 'platform:developer-standalone:vmware' => [ 'platform:developer-standalone:rpm', 'platform:developer-standalone:vmware:grind' ]
desc 'Refreshes the local RPM repository data and builds the SteamCannon developer standalone agent for VMware. Does NOT rebuild RPMs'
task 'platform:developer-standalone:vmware:grind' => 'rpm:repodata:force' do
  sh "sudo boxgrinder-build -W ./appliances/developer-standalone.appl -p vmware"
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



###
### RPM
###

desc 'Build all RPMs for the front-end appliance'
task 'platform:frontend:rpm' => [
  'rpm:steamcannon-agent',
  'rpm:mod_cluster',
]

desc 'Build all PRMs for the appserver appliance'
task 'platform:appserver:rpm' => [
  'rpm:steamcannon-agent',
  'rpm:jboss-as6',
  'rpm:jboss-as6-cloud-profiles',
  'rpm:torquebox-deployers',
  'rpm:torquebox-cloud-profiles-deployers',
  'platform:deps:torquebox:rpm',
] 

desc 'Build all RPMs for the postgresql appliance'
task 'platform:postgresql:rpm' => [
  'rpm:steamcannon-agent',
]

desc 'Build all RPMs for the developer standalone appliance'
task 'platform:developer-standalone:rpm' => [
  'platform:appserver:rpm',
  'platform:postgresql:rpm',
]

desc 'Build all RPMs for torquebox. Requires git://github.com/torquebox/torquebox-rpm.git in the parent directory.'
task 'platform:deps:torquebox:rpm' do
  Dir.chdir( '../torquebox-rpm' ) do
    sh 'rake rpm:all'
    sh 'rake rpm:repodata:force'
  end
end
