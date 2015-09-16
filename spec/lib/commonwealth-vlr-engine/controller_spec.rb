require 'spec_helper'

describe CommonwealthVlrEngine::Controller do

  class ControllerTestClass < ActionController::Base
      include CommonwealthVlrEngine::Controller
  end

  before { @obj = ControllerTestClass.new }

  describe 'create_img_sequence' do

    before do
      @image_files = ['bpl-dev:h702q641c', 'bpl-dev:h702q642n']
      @current_img_pid = 'bpl-dev:h702q642n'
      @img_seq = @obj.create_img_sequence @image_files, @current_img_pid
    end

    it 'should set the index to the correct value' do
      expect(@img_seq[:index]).to eq(2)
    end

    it 'should set the previous image to the correct value' do
      expect(@img_seq[:prev]).to eq(@image_files[0])
    end

    it 'should set the next image to the correct value' do
      expect(@img_seq[:next]).to eq(nil)
    end

  end

end