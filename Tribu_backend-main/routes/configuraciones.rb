require 'sinatra'
require 'json'
require 'bcrypt'

# Conexión a la base de datos
DB = Sequel.sqlite('db/Tribu.db')

# Endpoint 1: Cambiar Contraseña del Usuario
put '/configuraciones/usuario/:id/cambiar_contrasena' do
  begin
    usuario_id = params[:id].to_i
    data = JSON.parse(request.body.read)

    codigo = data['codigo']
    contrasena_actual = data['contrasena_actual']
    nueva_contrasena = data['nueva_contrasena']

    # Validar que todos los datos necesarios estén presentes
    if codigo.nil? || contrasena_actual.nil? || nueva_contrasena.nil?
      status 400
      return { error: 'Debe proporcionar el código, la contraseña actual y la nueva contraseña' }.to_json
    end

    # Obtener el usuario de la base de datos y verificar el código
    usuario = DB[:usuarios].where(id: usuario_id, codigo: codigo).first

    # Validar que el usuario existe y la contraseña actual coincide
    if usuario && usuario[:contrasena] == contrasena_actual
      # Encriptar la nueva contraseña
      nueva_contrasena_hash = BCrypt::Password.create(nueva_contrasena)
      DB[:usuarios].where(id: usuario_id).update(contrasena: nueva_contrasena_hash)
      status 200
      { message: 'Contraseña actualizada con éxito' }.to_json
    else
      status 401
      { error: 'El código o la contraseña actual no son correctos' }.to_json
    end
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end


# Endpoint 2: Obtener foto Asociados al Usuario
get '/configuraciones/usuario/:id/foto' do
  begin
    usuario_id = params[:id].to_i
    usuario = DB[:usuarios].where(id: usuario_id).select(:foto).first

    if usuario && usuario[:foto]
      status 200
      { foto: usuario[:foto] }.to_json
    else
      status 404
      { error: 'No se encontró una foto para el usuario especificado' }.to_json
    end
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end


# Endpoint 3: Obtener Publicaciones del Usuario
get '/configuraciones/usuario/:id/publicaciones' do
  begin
    usuario_id = params[:id].to_i
    publicaciones = DB[:posts].where(usuario_id: usuario_id).all

    if publicaciones.any?
      status 200
      { publicaciones: publicaciones }.to_json
    else
      status 404
      { error: 'No se encontraron publicaciones para el usuario especificado' }.to_json
    end
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end


# Endpoint 4: Eliminar Cuenta de Usuario
delete '/configuraciones/usuario/:codigo/eliminar_cuenta' do
  begin
    codigo_usuario = params[:codigo]
    usuario = DB[:usuarios].where(codigo: codigo_usuario).first

    if usuario
      usuario_id = usuario[:id]
      
      # Eliminar dependencias relacionadas con el usuario
      DB[:posts].where(usuario_id: usuario_id).delete # Eliminar publicaciones
      DB[:foto].where(usuario_id: usuario_id).delete # Eliminar fotos o archivos relacionados

      # Eliminar al usuario después de las dependencias
      DB[:usuarios].where(codigo: codigo_usuario).delete

      status 200
      { message: 'Cuenta de usuario eliminada con éxito' }.to_json
    else
      status 404
      { error: 'No se encontró el usuario con el código especificado' }.to_json
    end
  rescue SQLite3::ConstraintException => e
    status 500
    { error: "Error en el servidor: Fallo al eliminar registros dependientes (FOREIGN KEY constraint failed)" }.to_json
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end


# Endpoint 5: Cerrar Sesión de Usuario
post '/configuraciones/usuario/:id/cerrar_sesion' do
  begin
    usuario_id = params[:id].to_i
    # Aquí podrías implementar lógica para manejar el cierre de sesión
    # Por ejemplo, eliminando tokens de autenticación de una tabla de sesiones
    status 200
    { message: 'Sesión cerrada con éxito para el usuario' }.to_json
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end

# Endpoint 6: Cambiar Carrera del Usuario
put '/configuraciones/usuario/:codigo/cambiar_carrera' do
  begin
    codigo_usuario = params[:codigo]
    data = JSON.parse(request.body.read)

    nueva_carrera_id = data['carrera_id']
    if nueva_carrera_id.nil?
      status 400
      return { error: 'Debe proporcionar el ID de la nueva carrera (carrera_id)' }.to_json
    end

    # Verificar si el usuario existe
    usuario = DB[:usuarios].where(codigo: codigo_usuario).first

    if usuario
      # Actualizar el campo `carrera_id` del usuario
      DB[:usuarios].where(codigo: codigo_usuario).update(carrera_id: nueva_carrera_id)
      status 200
      { message: 'Carrera actualizada con éxito' }.to_json
    else
      status 404
      { error: 'No se encontró el usuario especificado' }.to_json
    end
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end