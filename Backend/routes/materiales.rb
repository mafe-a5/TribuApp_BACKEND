require 'sinatra'
require './config/models'

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