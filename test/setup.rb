ENV['RACK_ENV'] ||= 'test'
require 'pry'
require 'minitest/autorun'
require 'rack/test'
require './app.rb'
