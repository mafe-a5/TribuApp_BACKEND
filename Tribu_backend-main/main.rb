require 'sinatra'
require 'sequel'
require 'json'

# Configuración de Sinatra
set :public_folder, File.dirname(__FILE__) + '/public'
set :views, File.dirname(__FILE__) + '/views'
set :protection, except: :frame_options
set :bind, '0.0.0.0'
set :port, 8080

# CORS: Permitir acceso desde cualquier origen
before do
  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Allow-Methods' => ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
          'Access-Control-Allow-Headers' => 'Content-Type'
end

# Responder a las solicitudes OPTIONS
options '*' do
  response.headers['Allow'] = 'HEAD,GET,PUT,POST,DELETE,OPTIONS'
  response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
  200
end

# Conexión a la base de datos
DB = Sequel.sqlite('db/Tribu.db')  # Asegúrate de que la ruta de la base de datos es correcta

# Cargar configuración de la base de datos y modelos
require_relative 'configs/database'
require_relative 'configs/models'

# Incluir archivos de rutas
require_relative 'routes/notificaciones'  # Rutas específicas de notificaciones
require_relative 'routes/perfil_alumnos'
require_relative 'routes/Tribu_Busqueda'
require_relative 'routes/cursos'
require_relative 'routes/configuraciones'


# Incluir todos los archivos de rutas en la carpeta `routes`
Dir[File.join(__dir__, 'routes', '*.rb')].each { |file| require_relative file }

# Ruta de bienvenida para verificar que el servidor está en funcionamiento
get '/' do
  erb :home
end
