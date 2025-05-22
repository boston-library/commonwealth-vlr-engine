# frozen_string_literal: true

module CommonwealthVlrEngine
  module Document
    # Render citations for the document
    class CitationComponent < Blacklight::Document::CitationComponent
      def render_citation(citation_style)
        public_send("render_#{citation_style}_citation") if helpers.citation_styles.include?(citation_style)
      end

      def render_mla_citation
        citation_output = ''
        citation_output += names_for_citation('mla').presence.to_s
        citation_output += title_for_citation('mla')
        citation_output += publishing_data_for_citation.presence.to_s
        citation_output += if @document[:date_start_dtsi]
                             date_for_citation(@document[:date_start_dtsi], 'mla')
                           else
                             'n.d. '
                           end
        citation_output += "Web. #{Time.zone.today.strftime('%d %b %Y')}. "
        citation_output += "&lt;#{url_for_citation}&gt;."
        citation_output.gsub(/\.\./, '.')
      end

      def render_apa_citation
        citation_output = ''
        names = names_for_citation('apa')
        citation_output += names if names
        title_date_info = []
        title_date_info << if @document[:date_start_dtsi]
                             date_for_citation(@document[:date_start_dtsi], 'apa')
                           else
                             '(n.d.). '
                           end
        title_date_info << title_for_citation('apa')
        if @document[:genre_basic_ssim]
          title_date_info[1] = title_date_info[1].dup.insert(-3, " [#{genre_for_citation(@document[:genre_basic_ssim].first)}]")
        end
        title_date_info.reverse! unless names
        citation_output += title_date_info.join('')
        citation_output += "Retrieved from #{url_for_citation}"
        citation_output.gsub(/\.\./, '.')
      end

      def render_chicago_citation
        citation_output = ''
        citation_output += names_for_citation('chicago').presence.to_s
        citation_output += title_for_citation('chicago')
        citation_output += "#{genre_for_citation(@document[:genre_basic_ssim].first)}. " if @document[:genre_basic_ssim]
        citation_output += publishing_data_for_citation.presence.to_s
        citation_output += "#{@document[:date_tsim].first}. " if @document[:date_tsim]
        citation_output += if @document[:hosting_status_ssi] == 'hosted'
                             "<em>#{t('blacklight.application_name')}</em>, "
                           else
                             "<em>#{helpers.oai_inst_name(@document)}</em>, "
                           end
        citation_output += "#{url_for_citation} "
        citation_output += "(accessed #{Time.zone.today.strftime('%B %d, %Y')})."
        citation_output.gsub(/\.\./, '.')
      end

      def render_wikipedia_citation
        citation_output = '<code>'
        citation_output += '{{cite web'
        citation_output += " | title=#{helpers.render_title(@document)}"
        citation_output += if @document[:hosting_status_ssi] == 'hosted'
                             ' | website=DigitalCommonwealth.org'
                           else
                             " | website=#{helpers.oai_inst_name(@document)}"
                           end
        citation_output += " | date=#{@document[:date_tsim].first}" if @document[:date_tsim]
        citation_output += " | url=#{url_for_citation}"
        citation_output += " | accessdate=#{Time.zone.today.strftime('%B %-d, %Y')}}}"
        citation_output += '</code>'
        citation_output.html_safe
      end

      # create a list of creator names
      # TODO: need a way to distinguish corporate names from personal
      def names_for_citation(citation_style)
        return if @document[:name_tsim].blank?

        names = []
        all_names = @document[:name_tsim]
        all_names.map! { |n| n.gsub(/, [[d\.][ca\.][b\.] ]*\d.*/, '') }
        # for APA, names should be "Lastname, F." format
        if citation_style == 'apa'
          all_names = all_names.map do |n|
            if n.match?(/\A[\w\-']*, [A-Z]/)
              "#{n.match(/\A[\w\-']*, [A-Z]/)}."
            else
              n
            end
          end
        end
        # for MLA and Chicago, last personal name in list should be "Firstname Lastname" format
        if (citation_style == 'mla' || citation_style == 'chicago') && all_names.length > 1
          all_names[-1] = all_names.last.split(', ').reverse.join(' ')
        end
        names.concat(all_names)

        # if multiple creators, put ', ' between each, but ', and/& ' before last one
        name_output = ''
        name_and = citation_style == 'apa' ? '&' : 'and'
        if names.length > 1
          0.upto(names.length - 1) do |index|
            if index == names.length - 1
              name_output += "#{name_and} #{names[index]}"
            else
              name_output += "#{names[index]}, "
            end
          end
        else
          name_output += names.first
        end
        "#{name_output}. "
      end

      # return the publication info
      def publishing_data_for_citation
        return unless @document[:pubplace_tsi] || @document[:publisher_tsi]

        publishing_output = ''
        publishing_output += @document[:pubplace_tsi] if @document[:pubplace_tsi]
        publishing_output += ': ' if @document[:pubplace_tsi] && @document[:publisher_tsi]
        publishing_output += @document[:publisher_tsi] if @document[:publisher_tsi]
        "#{publishing_output.gsub(/[\[\]]/, '')}#{@document[:date_tsim] ? ',' : '.'} "
      end

      # return date with formatting
      def date_for_citation(date_start, citation_style)
        date_components = date_start.gsub(/(-01-01)*T[\d:]*Z\z/, '').split('-')
        if citation_style == 'mla'
          date_components[1] = Date::ABBR_MONTHNAMES[date_components[1].to_i] if date_components[1]
          "#{date_components.reverse.join(' ')}. "
        elsif citation_style == 'apa'
          apa_date_raw = date_components[0]
          apa_date_raw += ", #{Date::MONTHNAMES[date_components[1].to_i]}" if date_components[1]
          apa_date_raw += " #{date_components[2].to_i}" if date_components[2]
          "(#{apa_date_raw}). "
        end
      end

      # return the document title with formatting
      def title_for_citation(citation_style)
        if citation_style == 'mla'
          "<em>#{helpers.render_title(@document)}</em>. "
        elsif citation_style == 'chicago'
          "\"#{helpers.render_title(@document)}.\" "
        else
          "#{helpers.render_title(@document)}. "
        end
      end

      # return the genre as a singular value
      def genre_for_citation(genre)
        genre.gsub(/s\z/, '')
      end

      # return the URL for the current page
      # prefer ARK when available
      def url_for_citation
        @document[:identifier_uri_ss].presence || solr_document_url(@document)
      end
    end
  end
end
