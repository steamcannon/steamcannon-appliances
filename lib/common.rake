###
### Sanity-checking and verification
###

task 'dist:sanity'=>[ 'dist:sanity:dirs', 'dist:sanity:versions' ] 

task 'dist:sanity:dirs' do
  [ 
    '../rumpler',
    '../torquebox-rpm',
    '../steamcannon-rpm',
    '../steamcannon-agent-rpm',
    '../deltacloud-rpm',
    '../steamcannon-agent',
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
  steamcannon_agent_version = determine_value( './specs/steamcannon-agent.spec', 'steamcannon_agent_version' )
end

task 'dist:sanity:versions:verify' => [ 'dist:sanity:versions' ] do
  puts "TorqueBox build number...#{torquebox_version}"
  puts "SteamCannon version......#{steamcannon_version}"
  puts "SteamCannon Agent version......#{steamcannon_agent_version}"
  puts "Deltacloud version.......#{deltacloud_version}"
  print "Type 'y' if these versions are acceptable: "
  c = STDIN.gets.strip
  if ( c.downcase != 'y' )
    fail "You didn't type 'y'"
  end
end
