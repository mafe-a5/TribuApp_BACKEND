require 'sinatra'
require 'json'

# Conexión a la base de datos
DB = Sequel.sqlite('db/Tribu.db')

# Endpoint 1: Obtener Perfil de un Usuario por su Código
get '/usuarios/:codigo' do
  begin
    codigo = params[:codigo]
    usuario = DB[:usuarios].where(codigo: codigo).first

    if usuario
      status 200
      { usuario: usuario }.to_json
    else
      status 404
      { error: 'No se encontró el perfil del usuario' }.to_json
    end
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end

# Endpoint 2: Buscar Usuarios por Nombre
get '/usuarios/buscar/nombre' do
  begin
    nombre = params[:nombre]
    if nombre.nil? || nombre.empty?
      status 400
      return { error: 'Debe proporcionar un nombre para buscar' }.to_json
    end

    usuarios = DB[:usuarios].where(Sequel.ilike(:nombre, "%#{nombre}%")).all

    if usuarios.any?
      status 200
      { usuarios: usuarios }.to_json
    else
      status 404
      { error: 'No se encontraron usuarios con el nombre especificado' }.to_json
    end
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end

get '/usuarios/buscar/correo' do
  begin
    correo = params[:correo]
    if correo.nil? || correo.empty?
      status 400
      return { error: 'Debe proporcionar un correo para buscar' }.to_json
    end

    usuarios = DB[:usuarios].where(correo: correo).all

    if usuarios.any?
      status 200
      { usuarios: usuarios }.to_json
    else
      status 404
      { error: 'No se encontraron usuarios con el correo especificado' }.to_json
    end
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end

# Endpoint 4: Buscar Usuarios por Celular (coincidencia exacta)
get '/usuarios/buscar/celular' do
  begin
    celular = params[:celular]
    if celular.nil? || celular.empty?
      status 400
      return { error: 'Debe proporcionar un número de celular para buscar' }.to_json
    end

    usuarios = DB[:usuarios].where(celular: celular).all

    if usuarios.any?
      status 200
      { usuarios: usuarios }.to_json
    else
      status 404
      { error: 'No se encontraron usuarios con el número de celular especificado' }.to_json
    end
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end

# Endpoint 5: Actualizar Perfil de un Usuario
put '/usuarios/:codigo' do
  begin
    codigo = params[:codigo]
    data = JSON.parse(request.body.read)

    nombre = data['nombre']
    correo = data['correo']
    celular = data['celular']
    foto = data['foto']

    if nombre.nil? && correo.nil? && celular.nil? && foto.nil?
      status 400
      return { error: 'Debe proporcionar al menos un campo para actualizar' }.to_json
    end

    # Crea un hash con los valores actualizables
    actualizacion = {}
    actualizacion[:nombre] = nombre if nombre
    actualizacion[:correo] = correo if correo
    actualizacion[:celular] = celular if celular
    actualizacion[:foto] = foto if foto

    updated = DB[:usuarios].where(codigo: codigo).update(actualizacion)
    if updated > 0
      status 200
      { message: 'Perfil del usuario actualizado con éxito' }.to_json
    else
      status 404
      { error: 'No se encontró el perfil del usuario para actualizar' }.to_json
    end
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end
