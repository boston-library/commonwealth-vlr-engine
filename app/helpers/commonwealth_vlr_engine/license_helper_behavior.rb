# methods related to rendering license values
module CommonwealthVlrEngine
  module LicenseHelperBehavior
    # returns the CC license terms code for use in URLs, etc.
    def cc_terms_code(license)
      license.match(/\s[BYNCDSA-]{2,}/).to_s.strip.downcase
    end

    # returns a link to a CC license
    def cc_url(license)
      terms_code = cc_terms_code(license)
      "http://creativecommons.org/licenses/#{terms_code}/3.0"
    end

    # insert an icon and link to CC licenses
    def render_cc_license(license)
      terms_code = cc_terms_code(license)
      link_to(image_tag("//i.creativecommons.org/l/#{terms_code}/3.0/80x15.png",
                        alt: 'CC ' + terms_code.upcase + ' icon',
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
