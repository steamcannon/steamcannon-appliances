
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

def scribble_s3
  copy( s3_config_file_name, s3_config_file_bak )
  config = YAML.load_file( s3_config_file_name )
  config['bucket'] = config['bucket'] + "-" + rand(10000).to_s
  File.open( s3_config_file_name, 'w' ) do |out|
    YAML.dump( config, out )
  end
end

def restore_s3
  move( s3_config_file_bak, s3_config_file_name )
end

def s3_config_file_name
  "#{ENV['HOME']}/.boxgrinder/plugins/s3"
end

def s3_config_file_bak
  s3_config_file_name + ".bak"
end

class BuildVersion
  include Singleton
  
  attr_accessor :steamcannon, :steamcannon_agent, :torquebox, :deltacloud, :torquebox_rpm
  
  def initialize()
    @steamcannon       = nil
    @steamcannon_agent = nil
    @torquebox         = nil
    @deltacloud        = '0.0.8.1'
    @torquebox_rpm     = '1.0.0.Beta23.SNAPSHOT'  

    torquebox_versions = {}
    [ 
      './specs/torquebox-deployers.spec',
      './specs/torquebox-cloud-profiles-deployers.spec',
      '../torquebox-rpm/specs/torquebox-rubygems.spec',
    ].each do |spec|
      torquebox_versions[spec] = determine_value( spec, 'torquebox_build_number' )
    end
    if ( torquebox_versions.values.uniq.size == 1 )
      @torquebox = torquebox_versions.values.uniq.first
    else
      puts "TorqueBox build number mismatch!"
      torquebox_versions.each do |spec, ver|
        puts "  #{ver} - #{spec}"
      end
      fail( "TorqueBox build number mismatch" )
    end
    @steamcannon = determine_value( './specs/steamcannon.spec', 'steamcannon_version' )
    @steamcannon_agent = determine_value( './specs/steamcannon-agent.spec', 'steamcannon_agent_version' )
  end

end

