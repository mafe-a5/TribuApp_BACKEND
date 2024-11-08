class CreateCursos < ActiveRecord::Migration[7.2]
  def change
    create_table :cursos do |t|
      t.string :nombre
      t.references :usuario, foreign_key: true
      t.timestamps
    end
  end
end