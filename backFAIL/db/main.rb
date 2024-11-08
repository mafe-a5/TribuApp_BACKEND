require 'sinatra'
require 'sinatra/activerecord'
require './models'

set :database_file, "config/database.yml"

# Ver perfil
get '/usuarios/:id' do
  usuario = Usuario.find(params[:id])
  usuario.to_json(include: :carrera)
end

# Editar perfil
put '/usuarios/:id' do
  usuario = Usuario.find(params[:id])
  usuario.update(
    codigo: params[:codigo],
    correo: params[:correo],
    nombre: params[:nombre],
    celular: params[:celular],
    foto: params[:foto],
    contrasenia: params[:contrasenia],
    carrera_id: params[:carrera_id]
  )
  usuario.to_json
end

# Ver cursos de usuario
get '/usuarios/:usuario_id/cursos' do
  cursos = Curso.where(usuario_id: params[:usuario_id])
  cursos.to_json
end

# Crear curso
post '/usuarios/:usuario_id/cursos' do
  curso = Curso.create(
    nombre: params[:nombre],
    usuario_id: params[:usuario_id]
  )
  curso.to_json
end

# Editar curso
put '/cursos/:id' do
  curso = Curso.find(params[:id])
  curso.update(nombre: params[:nombre])
  curso.to_json
end

# Ver materiales de curso
get '/cursos/:curso_id/materiales' do
  materiales = Material.where(curso_id: params[:curso_id])
  materiales.to_json
end

# Crear material para curso
post '/cursos/:curso_id/materiales' do
  material = Material.create(
    nombre: params[:nombre],
    tipo: params[:tipo],
    fecha_subida: params[:fecha_subida],
    enlace: params[:enlace],
    curso_id: params[:curso_id]
  )
  material.to_json
end

# Editar material
put '/materiales/:id' do
  material = Material.find(params[:id])
  material.update(
    nombre: params[:nombre],
    tipo: params[:tipo],
    fecha_subida: params[:fecha_subida],
    enlace: params[:enlace]
  )
  material.to_json
end