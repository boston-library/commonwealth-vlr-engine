# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommonwealthVlrEngine::Document::CitationComponent, type: :component do
  let(:item_pid) { 'bpl-dev:h702q6403' }
  let(:document) { SolrDocument.find(item_pid) }
  let(:ark_link) { "http://ark-dc3dev.bpl.org/ark:/50959/#{item_pid.split(':').last}" }

  it 'renders the component with all styles' do
    render_inline(described_class.new(document: document))

    expect(page).to have_selector('.document-title-for-citation')
    expect(page).to have_css('h4', count: 4)
  end

  describe '#render_mla_citation' do
    it 'returns a properly formatted citation' do
      render_inline(described_class.new(document: document))

      expect(page).to have_content("Beauregard. 501 Broadway, New York: Published by E & H. T. Anthony, 1859. Web. #{Time.current.strftime("%d %b %Y")}. <#{ark_link}>.")
    end
  end

  describe '#render_apa_citation' do
    it 'returns a properly formatted citation' do
      render_inline(described_class.new(document: document))

      expect(page).to have_content("Beauregard [Photograph]. (1859). Retrieved from #{ark_link}")
    end
  end

  describe '#render_chicago_citation' do
    it 'returns a properly formatted citation' do
      render_inline(described_class.new(document: document))

      expect(page).to have_content("\"Beauregard.\" Photograph. 501 Broadway, New York: Published by E & H. T. Anthony, [ca. 1859–1870]. Totally Awesome Library Digital Collections, #{ark_link}")
    end
  end

  describe '#render_wikipedia_citation' do
    it 'returns a properly formatted citation' do
      render_inline(described_class.new(document: document))

      expect(page).to have_content("{{cite web | title=Beauregard | website=DigitalCommonwealth.org | date=[ca. 1859–1870] | url=#{ark_link} | accessdate=#{Time.current.strftime("%B %d, %Y")}}}")
    end
  end
end
