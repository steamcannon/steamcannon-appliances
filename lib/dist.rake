
steamcannon_version       = nil
steamcannon_agent_version = nil
torquebox_version         = nil
deltacloud_version        = '0.0.8.1'
torquebox_rpm_version     = '1.0.0.Beta23.SNAPSHOT'

##
## Appliances
##

task 'dist:appliance:vmware' => 'dist:rpm' do
  sh "boxgrinder-build -W ./appliances/steamcannon.appl -p vmware"
end

task 'dist:appliance:vmware:only' do
  sh "boxgrinder-build -W ./appliances/steamcannon.appl -p vmware"
end

task 'dist:appliance:ec2' => 'dist:rpm' do
  sh 'boxgrinder-build -W ./appliances/steamcannon.appl -p ec2 -d ebs'
end

task 'dist:appliance:ec2:only' do
  sh 'boxgrinder-build -W ./appliances/steamcannon.appl -p ec2 -d ebs'
end

task 'dist:appliance:ami' => 'dist:rpm' do
  begin
    interrupt_handler = proc{ restore_s3 }
    trap "SIGINT", interrupt_handler
    scribble_s3
    sh 'boxgrinder-build -W ./appliances/steamcannon.appl -p ec2 -d ami'
  ensure
    restore_s3
  end
end

task 'dist:appliance:ami:only' do
  begin
    interrupt_handler = proc{ restore_s3 }
    trap "SIGINT", interrupt_handler
    scribble_s3
    sh 'boxgrinder-build -W ./appliances/steamcannon.appl -p ec2 -d ami'
  ensure
    restore_s3
  end
end

task 'dist:appliance:clean' => [ 'dist:rpm:clean', 'dist:rumpler:clean' ] do
  sh "rm -Rf build/topdir"
  sh "rm -Rf build/appliances"
end

###
### RPM
###

task 'dist:rpm:clean'=>[ 
  'dist:rpm:torquebox:clean', 
  'dist:rpm:deltacloud:clean', 
  'dist:rpm:steamcannon:clean'
]

task 'dist:rpm'=>[ 
  'dist:rpm:torquebox', 
  'dist:rpm:deltacloud', 
  'dist:rpm:steamcannon', 
  'dist:rpm:core',
]

task 'dist:rpm:core' => [
  'rpm:jboss-as6',
  'rpm:torquebox-deployers',
  'rpm:steamcannon-deltacloud-core-deployment',
  'rpm:steamcannon',
  'rpm:repodata:force',
]

task 'dist:rpm:torquebox' => 'dist:rumpler:torquebox' do
  Dir.chdir( '../torquebox-rpm' ) do
    sh 'rake rpm:all'
    sh 'rake rpm:repodata:force'
  end
end

task 'dist:rpm:deltacloud' => 'dist:rumpler:deltacloud' do
  Dir.chdir( '../deltacloud-rpm' ) do
    sh 'rake rpm:all'
    sh 'rake rpm:repodata:force'
  end
end

task 'dist:rpm:steamcannon' => 'dist:rumpler:steamcannon' do
  Dir.chdir( '../steamcannon-rpm' ) do
    sh 'rake rpm:all'
    sh 'rake rpm:repodata:force'
  end
end

task 'dist:rpm:torquebox:clean' do
  sh 'rm -Rf ../torquebox-rpm/build/topdir' 
end

task 'dist:rpm:deltacloud:clean' do
  sh 'rm -Rf ../deltacloud-rpm/build/topdir'
end

task 'dist:rpm:steamcannon:clean' do
  sh 'rm -Rf ../steamcannon-rpm/build/topdir' 
end


###
### Rumpler
###

task 'dist:rumpler'=> [ 
  'dist:rumpler:torquebox', 
  'dist:rumpler:deltacloud', 
  'dist:rumpler:steamcannon'
]

task 'dist:rumpler:clean'=> [ 
  'dist:rumpler:torquebox:clean', 
  'dist:rumpler:deltacloud:clean', 
  'dist:rumpler:steamcannon:clean'
]

task 'dist:rumpler:torquebox' => [ 'dist:sanity:versions:verify' ] do
  puts "rumpling torquebox-rpm"
  Dir.chdir( "../torquebox-rpm" ) do
    FileUtils.mkdir_p( 'specs/gems' )
    if ( Dir[ 'specs/gems/*.spec' ].empty? )
      sh "../rumpler/bin/rumpler -r gemfiles/root.yml -o ./specs/gems/ -n torquebox-rubygems-dependencies -V #{torquebox_rpm_version}"
    else
      puts "INFO: specs present, not rumpling"
    end
  end
end

task 'dist:rumpler:deltacloud' => [ 'dist:sanity:versions:verify' ] do
  puts "rumpling deltacloud-rpm"
  Dir.chdir( "../deltacloud-rpm" ) do
    FileUtils.mkdir_p( 'specs' )
    if ( Dir[ 'specs/*.spec' ].empty? )
      sh "../rumpler/bin/rumpler -g steamcannon-deltacloud-core -v #{deltacloud_version} -o specs -r ../torquebox-rpm/gemfiles/root.yml"
    else
      puts "INFO: specs present, not rumpling"
    end
  end
end

task 'dist:rumpler:steamcannon' => [ 'dist:sanity:versions:verify' ] do
  puts "rumpling steamcannon-rpm"
  Dir.chdir( "../steamcannon" ) do
    sh "git fetch origin"
    sh "git checkout -f #{steamcannon_version}"
    FileUtils.mkdir_p( '../steamcannon-rpm/specs' )
    if ( Dir[ '../steamcannon-rpm/specs/*.spec' ].empty? )
      sh "../rumpler/bin/rumpler -a -v #{steamcannon_version} -o ../steamcannon-rpm/specs -r ../torquebox-rpm/gemfiles/root.yml"
    else
      puts "INFO: specs present, not rumpling"
    end
  end
end

task 'dist:rumpler:torquebox:clean' do
  sh 'rm -Rf ../torquebox-rpm/specs/gems' 
end

task 'dist:rumpler:deltacloud:clean' do
  sh 'rm -Rf ../deltacloud-rpm/specs' 
end

task 'dist:rumpler:steamcannon:clean' do 
  sh 'rm -Rf ../steamcannon-rpm/specs' 
end



