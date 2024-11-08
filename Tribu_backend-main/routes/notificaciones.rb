require 'sinatra'
require 'json'

# Conexión a la base de datos
DB = Sequel.sqlite('db/Tribu.db')

# Endpoint 1: Listar Notificaciones o Filtrar por Usuario
get '/notificaciones' do
  usuario_id = params[:usuario_id]

  query = DB[:notificaciones]
  query = query.where(usuario_id: usuario_id) if usuario_id

  notificaciones = query.all

  if notificaciones.any?
    status 200
    { notificaciones: notificaciones }.to_json
  else
    status 404
    { error: 'No se encontraron notificaciones' }.to_json
  end
end

# Endpoint 2: Marcar una Notificación como Vista
put '/notificaciones/:id/vista' do
  notificacion_id = params[:id].to_i

  begin
    notificacion = DB[:notificaciones][id: notificacion_id]
    if notificacion
      DB[:notificaciones].where(id: notificacion_id).update(visto: 'Y')
      status 200
      { message: 'Notificación marcada como vista' }.to_json
    else
      status 404
      { error: 'No se encontró la notificación' }.to_json
    end
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end

# Endpoint 3: Crear una nueva notificación
post '/notificaciones' do
  data = JSON.parse(request.body.read)

  usuario_id = data['usuario_id']
  tipo_notificacion = data['tipo_notificacion']
  post_id = data['post_id'] # Asegurarse de que `post_id` esté incluido en los datos de la solicitud
  fecha = Time.now.strftime("%Y-%m-%d")
  visto = 'N'

  # Validación de datos
  if usuario_id.nil? || tipo_notificacion.nil? || post_id.nil?
    status 400
    return { error: 'Debe proporcionar usuario_id, tipo_notificacion y post_id' }.to_json
  end

  begin
    notificacion_id = DB[:notificaciones].insert(
      usuario_id: usuario_id,
      tipo_notificacion: tipo_notificacion,
      post_id: post_id,
      fecha: fecha,
      visto: visto
    )

    status 201
    { message: 'Notificación creada con éxito', notificacion_id: notificacion_id }.to_json
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end

