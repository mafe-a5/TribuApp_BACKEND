require 'sinatra'
require 'sequel'
require 'json'

# Conexión a la base de datos
DB = Sequel.sqlite('db/Tribu.db')

# Endpoint 1: Listar todas las calificaciones de un profesor
get '/profesor/:id/calificaciones' do
  profesor_id = params[:id].to_i

  begin
    calificaciones = DB[:calificaciones]
                       .join(:usuarios, id: :usuario_id)
                       .where(profesor_id: profesor_id)
                       .select(:resenia, :estrella, :fecha_subida, Sequel[:usuarios][:nombre].as(:usuario_nombre))
                       .all

    if calificaciones.any?
      status 200
      { calificaciones: calificaciones }.to_json
    else
      status 404
      { error: 'No se encontraron calificaciones para este profesor' }.to_json
    end
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end

# Endpoint 2: Obtener promedio de calificaciones de un profesor
get '/profesor/:id/promedio-calificaciones' do
  profesor_id = params[:id].to_i

  begin
    calificaciones = DB[:calificaciones].where(profesor_id: profesor_id).all

    if calificaciones.any?
      promedio = calificaciones.map { |c| c[:estrella] }.sum.to_f / calificaciones.size
      status 200
      { promedio: promedio }.to_json
    else
      status 404
      { error: 'No se encontraron calificaciones para este profesor' }.to_json
    end
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end

# Endpoint 3: Crear una calificación para un profesor
post '/profesor/:id/calificacion' do
  profesor_id = params[:id].to_i
  data = JSON.parse(request.body.read)

  usuario_id = data['usuario_id']
  estrella = data['estrella']
  resenia = data['resenia']

  if usuario_id.nil? || estrella.nil? || resenia.nil?
    status 400
    return { error: 'Debe proporcionar usuario_id, estrella, y resenia' }.to_json
  end

  begin
    calificacion = DB[:calificaciones].insert(
      usuario_id: usuario_id,
      profesor_id: profesor_id,
      estrella: estrella,
      resenia: resenia,
      fecha_subida: Time.now
    )

    status 201
    { message: 'Calificación creada con éxito', calificacion: calificacion }.to_json
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end

# Endpoint 4: Buscar usuarios por nombre o código
get '/usuarios/buscar' do
  nombre = params[:nombre]
  codigo = params[:codigo]

  query = DB[:usuarios]
  query = query.where(Sequel.ilike(:nombre, "%#{nombre}%")) if nombre
  query = query.where(codigo: codigo) if codigo

  usuarios = query.all

  if usuarios.any?
    status 200
    { usuarios: usuarios }.to_json
  else
    status 404
    { error: 'No se encontraron usuarios que coincidan con los criterios de búsqueda' }.to_json
  end
end


# Endpoint 5: Buscar profesores por nombre o correo
get '/profesores/buscar' do
  nombre = params[:nombre]
  correo = params[:correo]

  query = DB[:profesores]
  query = query.where(Sequel.ilike(:nombre, "%#{nombre}%")) if nombre
  query = query.where(correo: correo) if correo

  profesores = query.all

  if profesores.any?
    status 200
    { profesores: profesores }.to_json
  else
    status 404
    { error: 'No se encontraron profesores que coincidan con los criterios de búsqueda' }.to_json
  end
end

# Endpoint 6: Buscar cursos por nombre o nivel
get '/cursos/buscar' do
  nombre = params[:nombre]
  nivel_id = params[:nivel_id]

  query = DB[:cursos]
  query = query.where(Sequel.ilike(:nombre, "%#{nombre}%")) if nombre
  query = query.where(nivel_id: nivel_id) if nivel_id

  cursos = query.all

  if cursos.any?
    status 200
    { cursos: cursos }.to_json
  else
    status 404
    { error: 'No se encontraron cursos que coincidan con los criterios de búsqueda' }.to_json
  end
end

# Endpoint 7: Buscar posts por descripción o fecha
get '/posts/buscar' do
  descripcion = params[:descripcion]
  fecha = params[:fecha_subida_post]

  query = DB[:posts]
  query = query.where(Sequel.ilike(:descripcion, "%#{descripcion}%")) if descripcion
  query = query.where(fecha_subida_post: fecha) if fecha

  posts = query.all

  if posts.any?
    status 200
    { posts: posts }.to_json
  else
    status 404
    { error: 'No se encontraron posts que coincidan con los criterios de búsqueda' }.to_json
  end
end

# Endpoint 8: Buscar materiales por nombre o tipo
get '/materiales/buscar' do
  nombre = params[:nombre]
  tipo = params[:tipo]

  query = DB[:materiales]
  query = query.where(Sequel.ilike(:nombre, "%#{nombre}%")) if nombre
  query = query.where(tipo: tipo) if tipo

  materiales = query.all

  if materiales.any?
    status 200
    { materiales: materiales }.to_json
  else
    status 404
    { error: 'No se encontraron materiales que coincidan con los criterios de búsqueda' }.to_json
  end
end
