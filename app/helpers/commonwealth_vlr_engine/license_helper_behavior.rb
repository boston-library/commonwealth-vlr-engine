# frozen_string_literal: true

# methods related to rendering license values
module CommonwealthVlrEngine
  module LicenseHelperBehavior
    def cc_terms_code(license)
      license.match(/\((CC.*?)\)/)[1]
    end

    def cc_url(license)
      urls = {
        "CC BY-NC-ND" => "https://creativecommons.org/licenses/by-nc-nd/4.0/",
        "CC0" => "https://creativecommons.org/publicdomain/zero/1.0/"
      }

      urls[cc_terms_code(license)]
    end

    def cc_image_url(license)
      urls = {
        "CC BY-NC-ND" => "https://licensebuttons.net/l/by-nc-nd/3.0/80x15.png",
        "CC0" => "https://licensebuttons.net/p/zero/1.0/80x15.png"
      }
      
      urls[cc_terms_code(license)]
    end

    def render_cc_license(license)
      link_to(image_tag(cc_image_url(license),
                        alt: cc_terms_code(license) + ' icon',
                        class: 'cc_license_icon'),
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
