class CreateSerializationTests < ActiveRecord::Migration[5.2]
  def change
    create_table :serialization_tests do |t|
      t.integer :value
    end
  end
end
