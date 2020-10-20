# frozen_string_literal: true

# this is heavily based on ActiveFedora::File::Streaming
module CommonwealthVlrEngine
  module Streaming
    extend ActiveSupport::Concern

    # @param range [String] the Range HTTP header
    # @return [Stream] an object that responds to each
    def file_stream(uri, range = nil)
      uri = URI.parse(uri)
      FileBody.new(uri, stream_headers(range))
    end

    # @param range [String] from #stream
    # @return [Hash]
    def stream_headers(range, result = {})
      result['Range'] = range if range
      result
    end

    class FileBody
      attr_reader :uri, :headers
      def initialize(uri, headers)
        @uri = uri
        @headers = headers
      end

      def each(no_of_requests_limit = 3, &block)
        raise ArgumentError, 'HTTP redirect too deep' if no_of_requests_limit.zero?

        Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
          request = Net::HTTP::Get.new uri, headers
          http.request request do |response|
            case response
            when Net::HTTPSuccess
              response.read_body do |chunk|
                yield chunk
              end
            when Net::HTTPRedirection
              no_of_requests_limit -= 1
              @uri = URI(response['location'])
              each(no_of_requests_limit, &block)
            else
              raise "Couldn't get data from Fedora (#{uri}). Response: #{response.code}"
            end
          end
        end
      end
    end
  end
end
