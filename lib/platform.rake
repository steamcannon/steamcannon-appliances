
##
## Appliances
##

# -- VMware

task 'platform:frontend:vmware' => [ 'platform:frontend:rpm', 'platform:frontend:vmware:grind' ]
task 'platform:frontend:vmware:grind' => 'rpm:repodata:force' do
  sh "sudo boxgrinder-build -W ./appliances/postgresql.appl -p vmware"
end

task 'platform:appserver:vmware' => [ 'platform:appserver:rpm', 'platform:appserver:vmware:grind' ] 
task 'platform:appserver:vmware:grind' => 'rpm:repodata:force' do
  sh "sudo boxgrinder-build -W ./appliances/appserver.appl -p vmware"
end

task 'platform:postgresql:vmware' => [ 'platform:postgresql:rpm', 'platform:postgresql:vmware:grind' ]
task 'platform:postgresql:vmware:grind' => 'rpm:repodata:force' do
  sh "sudo boxgrinder-build -W ./appliances/postgresql.appl -p vmware"
end

task 'platform:developer-standalone:vmware' => [ 'platform:developer-standalone:rpm', 'platform:developer-standalone:vmware:grind' ]
task 'platform:developer-standalone:vmware:grind' => 'rpm:repodata:force' do
  sh "sudo boxgrinder-build -W ./appliances/developer-standalone.appl -p vmware"
end


# -- EC2

task 'platform:frontend:ec2' => [ 'platform:frontend:rpm', 'platform:frontend:ec2:grind' ]
task 'platform:frontend:ec2:grind' => 'rpm:repodata:force' do
  sh "boxgrinder-build -W ./appliances/frontend.appl -p ec2 -d ami"
end

task 'platform:appserver:ec2' => [ 'platform:appserver:rpm', 'platform:appserver:ec2:grind' ] 
task 'platform:appserver:ec2:grind' => 'rpm:repodata:force' do
  sh "boxgrinder-build -W ./appliances/appserver.appl -p ec2 -d ami"
end

task 'platform:postgresql:ec2' => [ 'platform:postgresql:rpm', 'platform:postgresql:ec2:grind' ]
task 'platform:postgresql:ec2:grind' => 'rpm:repodata:force' do
  sh "boxgrinder-build -W ./appliances/postgresql.appl -p ec2 -d ami"
end

task 'platform:developer-standalone:ec2' => [ 'platform:developer-standalone:rpm', 'platform:developer-standalone:ec2:grind' ]
task 'platform:developer-standalone:ec2:grind' => 'rpm:repodata:force' do
  sh "boxgrinder-build -W ./appliances/developer-standalone.appl -p ec2 -d ami"
end



###
### RPM
###


task 'platform:frontend:rpm' => [
  'rpm:steamcannon-agent',
  'rpm:mod_cluster',
]

task 'platform:appserver:rpm' => [
  'rpm:steamcannon-agent',
  'rpm:jboss-as6',
  'rpm:jboss-as6-cloud-profiles',
  'rpm:torquebox-deployers',
  'rpm:torquebox-cloud-profiles-deployers',
  'platform:deps:torquebox:rpm',
] 

task 'platform:postgresql:rpm' => [
  'rpm:steamcannon-agent',
]

task 'platform:developer-standalone:rpm' => [
  'platform:appserver:rpm',
  'platform:postgresql:rpm',
]

task 'platform:deps:torquebox:rpm' do
  Dir.chdir( '../torquebox-rpm' ) do
    sh 'rake rpm:all'
    sh 'rake rpm:repodata:force'
  end
end
