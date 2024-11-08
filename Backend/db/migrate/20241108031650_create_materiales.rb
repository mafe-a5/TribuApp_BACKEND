class CreateMateriales < ActiveRecord::Migration[7.2]
  def change
    create_table :materiales do |t|
      t.string :nombre
      t.string :tipo
      t.date :fecha_subida
      t.string :enlace
      t.references :curso, foreign_key: true
      t.timestamps
    end
  end
end