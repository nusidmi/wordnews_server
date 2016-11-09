class CreateAnnotationHistories < ActiveRecord::Migration
  def change
    create_table :annotation_histories do |t|
      t.integer :user_id
      t.integer :annotation_id
      t.integer :client_ann_id
      t.string :lang

      t.timestamps
    end
  end
end
