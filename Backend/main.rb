require 'sinatra'
require 'sinatra/activerecord'
require './config/models' 

set :database_file, 'config/database.yml'

Dir[File.join(__dir__, 'routes', '*.rb')].each { |file| require file }

get '/' do
  'Servidor de TribuApp Backend funcionando'
end