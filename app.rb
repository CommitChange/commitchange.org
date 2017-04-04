require './init.rb'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/cross_origin'
require 'sinatra/activerecord'
require 'rack/contrib'
require 'rack/ssl'
require 'rack/throttle'
require 'jwt'
require 'qx'
require 'param_validation'
require 'lib/auth'

class App < Sinatra::Base
  register Sinatra::CrossOrigin
  register Sinatra::ActiveRecordExtension
  configure :production do
    use Rack::SSL
    use Rack::Throttle::Hourly, max: 100
  end
  configure do
    enable :cross_origin
    set show_exceptions: false
    set :allow_origin, :any
    set :allow_methods, [:get, :post, :options, :put, :patch, :delete]
    set :expose_headers, ['Content-Type']
    use Rack::Logger
  end
  helpers do
    # Will throw a JWT error if the jwt is invalid in some way (caught by the error handlers below)
    def helper_get_valid_jwt
      jwt = request.cookies['jwt']
      return Auth.decode(jwt, @payload[:csrf_token]) if jwt.present?
    end
    def helper_set_preflight_options_headers
      response.headers["Allow"] = "GET,PATCH,POST,DELETE,OPTIONS"
      response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept, Authorization"
      response.headers["Access-Control-Allow-Credentials"] = 'true'
    end
  end
  before do
    bod = request.body.read
    if request.content_type && request.content_type.include?('json') && bod.present?
      @payload = HashWithIndifferentAccess.new(JSON.parse(bod))
    else # form data or query text
      @payload = params
    end
    puts "Request Payload: #{@payload}" if ENV['RACK_ENV'] == 'development'
  end
  get "/" do
    erb :root
  end
  # HTML routes
  get "/dashboard" do
    erb :dashboard
  end
  get "/settings" do
    erb :settings
  end
  get "/donate" do
    erb :donate
  end
  get "/campaigns" do
    erb :campaigns
  end
  get "/events" do
    erb :events
  end
  get "/campaign/:id*" do
    erb :campaign
  end
  get "/event/:id*" do
    erb :event
  end
  get "/reports" do
    erb :reports
  end
  get "/forms" do
    erb :forms
  end
  get "/form" do
    erb :form
  end
  get "/login" do
  end
  get "/logout" do
  end
  # API routes
  # TODO
end
