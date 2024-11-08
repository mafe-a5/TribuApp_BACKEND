class CreateUsuarios < ActiveRecord::Migration[7.2]
  def change
    create_table :usuarios do |t|
      t.string :codigo
      t.string :correo
      t.string :nombre
      t.string :celular
      t.string :foto
      t.string :contrasenia
      t.references :carrera, foreign_key: true
      t.timestamps
    end
  end
end