# frozen_string_literal: true

# This migration comes from commonwealth_vlr_engine (originally 20141104185610)
class ChangeCarouselSlidesToIiif < ActiveRecord::Migration[4.2]
  def change

    remove_column(:carousel_slides, :scale)
    add_column(:carousel_slides, :size, :string)
    change_column(:carousel_slides, :region, :string)

  end
end
