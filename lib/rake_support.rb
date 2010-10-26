
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
