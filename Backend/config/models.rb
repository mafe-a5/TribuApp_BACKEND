require 'sinatra/activerecord'

class Usuario < ActiveRecord::Base
  belongs_to :carrera
  has_many :cursos
  has_many :materiales, through: :cursos
end

class Carrera < ActiveRecord::Base
  has_many :usuarios
end

class Curso < ActiveRecord::Base
  belongs_to :usuario
  has_many :materiales
end

class Material < ActiveRecord::Base
  belongs_to :curso
end