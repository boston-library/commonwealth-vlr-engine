# frozen_string_literal: true

# methods related to rendering license values
module CommonwealthVlrEngine
  module LicenseHelperBehavior
    def cc_terms_code(license)
      license.match(/\((CC.*?)\)/)[1]
    end

    def cc_url(license)
      base_url = 'https://creativecommons.org/'
      terms_code = cc_terms_code(license)
      return "#{base_url}publicdomain/zero/1.0/" if terms_code == 'CC0'

      license_path = terms_code.split(' ').last.downcase
      "#{base_url}licenses/#{license_path}/4.0/"
    end

    def cc_image_url(license)
      base_url = 'https://licensebuttons.net/'
      terms_code = cc_terms_code(license)
      return "#{base_url}p/zero/1.0/80x15.png" if terms_code == 'CC0'

      license_path = terms_code.split(' ').last.downcase
      "#{base_url}l/#{license_path}/4.0/80x15.png"
    end

    def render_rs_icon(document)
      icon_slug = document[:rightsstatement_uri_ss].split('/')[-2].split('-').first
      link_to(image_tag("https://rightsstatements.org/files/icons/#{icon_slug}.Icon-Only.dark.svg",
                        alt: "#{document[:rightsstatement_ss]} icon",
                        id: 'rs_icon'),
              document[:rightsstatement_uri_ss],
              rel: 'license',
              id: 'rs_link',
              target: '_blank')
    end

    def render_cc_license(license)
      link_to(image_tag(cc_image_url(license),
                        alt: cc_terms_code(license) + ' icon',
                        id: 'cc_license_icon'),
              cc_url(license),
              rel: 'license',
              id: 'cc_license_link',
              target: '_blank')
    end

    # render reuse_allowed_ssi values for facet display
    def render_reuse(value)
      case value
      when 'no restrictions'
        'No known restrictions'
      when 'creative commons'
        'Creative Commons license'
      else
        'See item for details'
      end
    end
  end
end
