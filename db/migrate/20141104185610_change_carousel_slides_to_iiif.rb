class ChangeCarouselSlidesToIiif < ActiveRecord::Migration[4.2]
  def change

    remove_column(:carousel_slides, :scale)
    add_column(:carousel_slides, :size, :string)
    change_column(:carousel_slides, :region, :string)

  end
end
