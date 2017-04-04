require './app'
require 'sinatra/activerecord/rake'
Dir.glob('lib/tasks/*.rake').each{|r| load r}

# For sinatra-activerecord
namespace :db do
  task(:load_config){ require "./app" }
end
