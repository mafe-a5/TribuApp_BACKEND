require 'sinatra'
require 'json'

# Conexión a la base de datos
DB = Sequel.sqlite('db/Tribu.db')

# Endpoint 1: Obtener Curso por su ID
get '/cursos/:id' do
  begin
    curso_id = params[:id].to_i
    curso = DB[:cursos].where(id: curso_id).first

    if curso
      status 200
      { curso: curso }.to_json
    else
      status 404
      { error: 'No se encontró el curso con el ID especificado' }.to_json
    end
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end

# Endpoint 2: Buscar Cursos por Nombre (coincidencia parcial)
get '/cursos/buscar/nombre' do
  begin
    nombre = params[:nombre]
    if nombre.nil? || nombre.empty?
      status 400
      return { error: 'Debe proporcionar un nombre para buscar' }.to_json
    end

    cursos = DB[:cursos].where(Sequel.ilike(:nombre, "%#{nombre}%")).all

    if cursos.any?
      status 200
      { cursos: cursos }.to_json
    else
      status 404
      { error: 'No se encontraron cursos con el nombre especificado' }.to_json
    end
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end

# Endpoint 3: Buscar Cursos por Nivel (coincidencia exacta)
get '/cursos/buscar/nivel' do
  begin
    nivel_id = params[:nivel_id].to_i
    if nivel_id.zero?
      status 400
      return { error: 'Debe proporcionar un nivel_id válido para buscar' }.to_json
    end

    cursos = DB[:cursos].where(nivel_id: nivel_id).all

    if cursos.any?
      status 200
      { cursos: cursos }.to_json
    else
      status 404
      { error: 'No se encontraron cursos para el nivel especificado' }.to_json
    end
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end

# Endpoint 4: Listar Materiales por ID de Curso
get '/cursos/:id/materiales' do
  begin
    curso_id = params[:id].to_i
    materiales = DB[:materiales].where(post_id: curso_id).all

    if materiales.any?
      status 200
      { materiales: materiales }.to_json
    else
      status 404
      { error: 'No se encontraron materiales para el curso especificado' }.to_json
    end
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end

# Endpoint 5: Editar Materiales por ID del Curso y Material
put '/cursos/:id/materiales/:material_id' do
  begin
    curso_id = params[:id].to_i
    material_id = params[:material_id].to_i
    data = JSON.parse(request.body.read)

    # Parámetros permitidos para actualización
    nombre = data['nombre']
    tipo = data['tipo']
    fecha_subida = data['fecha_subida']
    enlace = data['enlace']

    # Crear un hash de los valores a actualizar
    actualizacion = {}
    actualizacion[:nombre] = nombre if nombre
    actualizacion[:tipo] = tipo if tipo
    actualizacion[:fecha_subida] = fecha_subida if fecha_subida
    actualizacion[:enlace] = enlace if enlace

    # Verificar si hay campos para actualizar
    if actualizacion.empty?
      status 400
      return { error: 'Debe proporcionar al menos un campo para actualizar' }.to_json
    end

    # Actualizar el material en la base de datos
    updated = DB[:materiales].where(id: material_id, post_id: curso_id).update(actualizacion)

    if updated > 0
      status 200
      { message: 'Material actualizado con éxito' }.to_json
    else
      status 404
      { error: 'No se encontró el material especificado para el curso' }.to_json
    end
  rescue StandardError => e
    status 500
    { error: "Error en el servidor: #{e.message}" }.to_json
  end
end