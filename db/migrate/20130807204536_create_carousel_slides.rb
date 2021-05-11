class CreateCarouselSlides < ActiveRecord::Migration[4.2]
  def change
    create_table :carousel_slides do |t|
      t.integer :sequence
      t.string :object_pid
      t.string :image_pid
      t.integer :scale
      t.text :region
      t.string :title
      t.string :institution
      t.string :context

      t.timestamps
    end
  end
end
