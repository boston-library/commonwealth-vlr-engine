# frozen_string_literal: true

require 'rails_helper'

describe CommonwealthVlrEngine::LicenseHelperBehavior do
  describe 'Rights Statements helpers' do
    let(:document) { SolrDocument.find('bpl-dev:g445cd14k') }

    describe '#render_rs_icon' do
      it 'renders the rights link and image' do
        expect(helper.render_rs_icon(document)).to include('href="' + document[:rightsstatement_uri_ss])
        expect(helper.render_rs_icon(document)).to include('src="https://rightsstatements.org/')
      end
    end
  end

  describe 'Creative Commons license helpers' do
    let(:license) { 'This work is licensed for use under a Creative Commons Attribution Non-Commercial No Derivatives License (CC BY-NC-ND).' }
    let(:cc_url) { 'https://creativecommons.org/licenses/by-nc-nd/4.0/' }
    let(:cc_image_url) { 'https://licensebuttons.net/l/by-nc-nd/4.0/80x15.png' }

    describe '#cc_terms_code' do
      it 'returns the right value' do
        expect(helper.cc_terms_code(license)).to eq('CC BY-NC-ND')
      end
    end

    describe '#cc_url' do
      it 'returns the right value' do
        expect(helper.cc_url(license)).to eq(cc_url)
      end
    end

    describe '#cc_image_url' do
      it 'returns the right value' do
        expect(helper.cc_image_url(license)).to eq(cc_image_url)
      end
    end

    describe '#render_cc_license' do
      it 'renders the CC link and image' do
        expect(helper.render_cc_license(license)).to include('href="' + cc_url)
        expect(helper.render_cc_license(license)).to include('src="' + cc_image_url)
      end
    end
  end

  describe 'render_reuse' do
    it 'returns the right value' do
      expect(helper.render_reuse('creative commons')).to eq 'Creative Commons license'
    end
  end
end
