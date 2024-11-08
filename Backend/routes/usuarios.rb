require 'sinatra'
require './config/models'

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