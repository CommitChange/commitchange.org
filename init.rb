ENV['RACK_ENV'] ||= 'development'

# Add the app root directory to the ruby load path
$LOAD_PATH.push(Dir.pwd)

# Load ENV variables from ./.env
if ['development', 'test'].include? ENV['RACK_ENV']
  require 'dotenv'
  Dotenv.load
end

# Import all other init files 
Dir['init/*.rb'].each{|f| require f}
