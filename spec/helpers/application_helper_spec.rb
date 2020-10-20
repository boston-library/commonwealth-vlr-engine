# frozen_string_literal: true

require 'rails_helper'

describe ApplicationHelper do
  let(:image_pid) { 'bpl-dev:h702q641c' }

  describe '#render_format' do
    it 'returns the right value' do
      expect(helper.render_format('Albums (Books)')).to eq('Albums/Scrapbooks')
      expect(helper.render_format('Correspondence')).to eq('Letters/Correspondence')
    end
  end

  describe '#render_format_index' do
    let(:opts) { { value: ['Maps'] } }
    it 'returns the right value' do
      expect(helper.render_format_index(opts)).to eq('Maps/Atlases')
    end
  end

  describe '#render_object_icon_path' do
    it 'returns the right value' do
      expect(helper.render_object_icon_path('sound recording')).to eq('commonwealth-vlr-engine/dc_audio-icon.png')
      expect(helper.render_object_icon_path('dfsdsdg')).to eq('commonwealth-vlr-engine/dc_text-icon.png')
    end
  end

  describe '#link_to_facet' do
    it 'creates a link to catalog#index with the facet params and display value' do
      expect(helper.link_to_facet('foo', 'bar_ssim', 'baz')).to include('search?f%5Bbar_ssim%5D%5B%5D=foo">baz')
    end

    it 'should use render_format if the field_name is "genre_basic_ssim"' do
      expect(helper.link_to_facet('Albums (Books)', 'genre_basic_ssim')).to include('search?f%5Bgenre_basic_ssim%5D%5B%5D=Albums+%28Books%29">Albums/Scrapbooks')
    end
  end

  describe '#link_to_facets' do
    it 'creates a link to catalog#index with the facet params' do
      expect(helper.link_to_facets(['foo', 'baz'], ['bar_ssim', 'quux_ssim'])).to include('f%5Bbar_ssim%5D%5B%5D=foo&amp;f%5Bquux_ssim%5D%5B%5D=baz')
    end
  end

  describe '#link_to_county_facet' do
    it 'creates a link to catalog#index with the facet params and display value' do
      expect(helper.link_to_county_facet('Foo', 'county_ssim')).to include('f%5Bcounty_ssim%5D%5B%5D=Foo+%28county%29">Foo County')
    end
  end

  describe '#datastream_disseminator_url' do
    it 'creates a path to the Fedora datastream' do
      expect(helper.datastream_disseminator_url(image_pid, 'accessMaster')).to eq("#{FEDORA_URL['url']}/objects/#{image_pid}/datastreams/accessMaster/content")
    end
  end

  describe '#iiif_image_tag' do
    it 'creates an image tag with a IIIF URI as the href' do
      expect(helper.iiif_image_tag(image_pid, {})).to include("#{IIIF_SERVER['url']}#{image_pid}/full/full/0/default.jpg")
    end
  end

  describe '#iiif_image_url' do
    it 'returns a IIIF URI' do
      expect(helper.iiif_image_url(image_pid, { size: 'pct:50', region: '0,0,100,100' })).to include("#{IIIF_SERVER['url']}#{image_pid}/0,0,100,100/pct:50/0/default.jpg")
    end
  end

  describe '#get_image_metadata' do
    it 'returns a hash with the height, width, and aspect ratio of the image' do
      expect(helper.get_image_metadata(image_pid)).to eq({ height: 2448, width: 1496, aspect_ratio: 0.6111111111111112 })
    end

    describe 'when IIIF server is unresponsive' do
      it 'returns a hash with the height and width of the image set to 0' do
        expect(helper.get_image_metadata('bpl-dev:xyz1234')).to eq({ height: 0, width: 0, aspect_ratio: 0 })
      end
    end
  end

  describe '#osd_nav_images' do
    it 'returns a hash with the path to the OpenSeadragon control images' do
      assets_root = File.join(CommonwealthVlrEngine.root, 'app', 'assets', 'images', 'commonwealth-vlr-engine', 'opeanseadragon')
      expect(JSON.parse(helper.osd_nav_images(assets_root))['zoomIn']['REST']).to eq("#{assets_root}/zoomin_rest.png")
    end
  end
end
