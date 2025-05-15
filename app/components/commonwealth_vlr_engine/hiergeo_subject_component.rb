# frozen_string_literal: true

module CommonwealthVlrEngine
  class HiergeoSubjectComponent < ViewComponent::Base
    attr_reader :geojson_feature

    def initialize(geojson_feature:, separator: I18n.t('blacklight.breadcrumb.separator'), separator_class: 'metadata_breadcrumb')
      @geojson_feature= geojson_feature
      @separator = separator
      @separator_class = separator_class
    end

    def render_hiergo_subject
      output_array = []
      hiergeo_hash = JSON.parse(geojson_feature).symbolize_keys[:properties]
      hiergeo_hash.each_key do |k|
        if k == 'continent'
          # only display continent if there are no other values
          output_array << helpers.link_to_facet(hiergeo_hash[k], geo_subject_link_field) if hiergeo_hash.length == 1
        elsif k == 'country' && hiergeo_hash[k] == 'United States'
          # display 'United States' only if no other values besides continent
          output_array << helpers.link_to_facet(hiergeo_hash[k], geo_subject_link_field) if hiergeo_hash.length == 2
        elsif k == 'county'
          output_array << helpers.link_to_facet("#{hiergeo_hash[k]} (county)", geo_subject_link_field)
        elsif k == 'island' || k == 'area' || k == 'province' || k == 'territory' || k == 'region'
          output_array << helpers.link_to_facet(hiergeo_hash[k], geo_subject_link_field) + " (#{k})"
        elsif k == 'other'
          place_type = hiergeo_hash[k].scan(/\([a-z\s]*\)/).last
          place_name = hiergeo_hash[k].gsub(/#{place_type}/, '').gsub(/\s\(\)\z/, '')
          output_array << helpers.link_to_facet(place_name, geo_subject_link_field) + " #{place_type}"
        else
          output_array << helpers.link_to_facet(hiergeo_hash[k], geo_subject_link_field)
        end
      end
      output_array.join(content_tag(:span, @separator, class: @separator_class)).html_safe
    end

    def geo_subject_link_field
      helpers.blacklight_config.geo_subject_link_field
    end

    def render?
      geojson_feature.present?
    end
  end
end
