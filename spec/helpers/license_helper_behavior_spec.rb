# frozen_string_literal: true

require 'rails_helper'

describe CommonwealthVlrEngine::LicenseHelperBehavior do
  describe 'Creative Commons license helpers' do
    let(:license) { 'This work is licensed for use under a Creative Commons Attribution Non-Commercial No Derivatives License (CC BY-NC-ND).' }
    let(:cc_url) { 'https://creativecommons.org/licenses/by-nc-nd/4.0/' }

    describe '#cc_terms_code' do
      it 'starts with CC' do
        expect(helper.cc_terms_code(license)).to start_with('CC')
      end
    end

    describe '#cc_url' do
      it 'returns the right value' do
        expect(helper.cc_url(license)).to start_with('https://creativecommons.org/')
      end
    end

    describe '#cc_image_url' do
      it 'returns the right value' do
        expect(helper.cc_image_url(license)).to start_with('https://licensebuttons.net/')
      end
    end

    describe '#render_cc_license' do
      it 'renders the CC link and image' do
        expect(helper.render_cc_license(license)).to include('href="' + cc_url)
        expect(helper.render_cc_license(license)).to include('src="https://licensebuttons.net/')
      end
    end
  end

  describe 'render_reuse' do
    it 'returns the correct value' do
      expect(helper.render_reuse('creative commons')).to eq 'Creative Commons license'
    end
  end
end
