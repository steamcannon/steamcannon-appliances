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
  BuildVersion.instance
end

task 'dist:sanity:versions:verify' => [ 'dist:sanity:versions' ] do
  puts "TorqueBox build number...#{BuildVersion.instance.torquebox}"
  puts "SteamCannon version......#{BuildVersion.instance.steamcannon}"
  puts "Deltacloud version.......#{BuildVersion.instance.deltacloud}"
  print "Type 'y' if these versions are acceptable: "
  c = STDIN.gets.strip
  if ( c.downcase != 'y' )
    fail "You didn't type 'y'"
  end
end

task 'dist:sanity:versions:steamcannon-agent:verify' => [ 'dist:sanity:versions' ] do
  puts "SteamCannon version......#{BuildVersion.instance.steamcannon}"
  puts "SteamCannon Agent version.......#{BuildVersion.instance.steamcannon_agent}"
  print "Type 'y' if these versions are acceptable: "
  c = STDIN.gets.strip
  if ( c.downcase != 'y' )
    fail "You didn't type 'y'"
  end
end
