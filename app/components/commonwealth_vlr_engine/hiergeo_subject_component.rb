# frozen_string_literal: true

module CommonwealthVlrEngine
  class HiergeoSubjectComponent < ViewComponent::Base
    attr_reader :document
    GEOJSON_FIELD = :subject_hiergeo_geojson_ssm
    GEO_SUBJECT_LINK_FIELD = 'subject_geographic_sim'

    def initialize(document:, separator: I18n.t('blacklight.breadcrumb.separator'), separator_class: 'metadata_breadcrumb')
      @document = document
      @separator = separator
      @separator_class = separator_class
    end

    def render_hiergo_subject
      output_array = []
      geojson_feature = document[GEOJSON_FIELD].first
      hiergeo_hash = JSON.parse(geojson_feature).symbolize_keys[:properties]
      hiergeo_hash.each_key do |k|
        if k == 'continent'
          # only display continent if there are no other values
          output_array << helpers.link_to_facet(hiergeo_hash[k], GEO_SUBJECT_LINK_FIELD) if hiergeo_hash.length == 1
        elsif k == 'country' && hiergeo_hash[k] == 'United States'
          # display 'United States' only if no other values besides continent
          output_array << helpers.link_to_facet(hiergeo_hash[k], GEO_SUBJECT_LINK_FIELD) if hiergeo_hash.length == 2
        elsif k == 'county'
          output_array << helpers.link_to_facet("#{hiergeo_hash[k]} (county)", GEO_SUBJECT_LINK_FIELD)
        elsif k == 'island' || k == 'area' || k == 'province' || k == 'territory' || k == 'region'
          output_array << helpers.link_to_facet(hiergeo_hash[k], GEO_SUBJECT_LINK_FIELD) + " (#{k})"
        elsif k == 'other'
          place_type = hiergeo_hash[k].scan(/\([a-z\s]*\)/).last
          place_name = hiergeo_hash[k].gsub(/#{place_type}/, '').gsub(/\s\(\)\z/, '')
          output_array << helpers.link_to_facet(place_name, GEO_SUBJECT_LINK_FIELD) + " #{place_type}"
        else
          output_array << helpers.link_to_facet(hiergeo_hash[k], GEO_SUBJECT_LINK_FIELD)
        end
      end
      output_array.join(content_tag(:span, @separator, class: @separator_class)).html_safe
    end

    def render?
      document[GEOJSON_FIELD].present?
    end
  end
end
