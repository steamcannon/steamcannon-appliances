
steamcannon_version = nil
torquebox_version   = nil
deltacloud_version  = '0.0.8.1'

##
## Appliances
##

task 'dist:appliance:vmware' => 'dist:rpm' do
  sh "sudo boxgrinder-build -W ./appliances/steamcannon.appl -p vmware"
end

task 'dist:appliance:vmware:only' do
  sh "sudo boxgrinder-build -W ./appliances/steamcannon.appl -p vmware"
end

###
### RPM
###

task 'dist:rpm:clean'=>[ 
  'dist:rpm:torquebox:clean', 
  'dist:rpm:deltacloud:clean', 
  'dist:rpm:steamcannon:clean', 
]

task 'dist:rpm'=>[ 
  'dist:rpm:torquebox', 
  'dist:rpm:deltacloud', 
  'dist:rpm:steamcannon', 
  'dist:rpm:core',
]

task 'dist:rpm:core' => [
  'core:rpm:jboss-as6',
  'core:rpm:torquebox-deployers',
  'core:rpm:steamcannon-deltacloud-core-deployment',
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
  FileUtils.rm_rf( '../torquebox-rpm/build/topdir' )
end

task 'dist:rpm:deltacloud' => 'dist:rumpler:deltacloud' do
  FileUtils.rm_rf( '../deltacloud-rpm/build/topdir' )
end

task 'dist:rpm:steamcannon' => 'dist:rumpler:steamcannon' do
  FileUtils.rm_rf( '../steamcannon-rpm/build/topdir' )
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

task 'dist:rumpler:torquebox' => [ 'verify-versions' ] do
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

task 'dist:rumpler:deltacloud' => [ 'verify-versions' ] do
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

task 'dist:rumpler:steamcannon' => [ 'verify-versions' ] do
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
  FileUtils.rm_rf( '../torquebox-rpm/specs/gems' )
end

task 'dist:rumpler:deltacloud' => 'dist:rumpler:deltacloud' do
  FileUtils.rm_rf( '../deltacloud-rpm/specs' )
end

task 'dist:rumpler:steamcannon' => 'dist:rumpler:steamcannon' do
  FileUtils.rm_rf( '../steamcannon-rpm/specs' )
end


###
### Sanity-checking and verification
###

task 'dist:sanity'=>[ 'dist:sanity:dirs', 'dist:sanity:versions' ] 

task 'dist:sanity:dirs' do
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

task 'dist:sanity:versions' do
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

task 'dist:sanity:versions:verify' => [ 'dist:sanity:versions' ] do
  puts "TorqueBox build number...#{torquebox_version}"
  puts "SteamCannon version......#{steamcannon_version}"
  puts "Deltacloud version.......#{deltacloud_version}"
  print "Type 'y' if these versions are acceptable: "
  c = STDIN.gets.strip
  if ( c.downcase != 'y' )
    fail "You didn't type 'y'"
  end
end
