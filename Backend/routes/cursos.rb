require 'sinatra'
require './config/models'

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