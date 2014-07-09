#
#   Author: Rohith
#   Date: 2014-06-20 11:45:32 +0100 (Fri, 20 Jun 2014)
#
#  vim:ts=2:sw=2:et
#
require 'httparty'
require 'xmlsimple'
require 'utils'
require 'config'

module Rundeck
  module Session
    include HTTParty
    [ :get, :post, :delete ].each do |m|
      define_method "#{m}" do |uri,content = {},parse = true|
        request( m, {
          :uri   => uri,
          :body  => content,
          :parse => parse
        } )  
      end
    end

    private
    def request method, options = {}
      result = nil
      Timeout::timeout( CONFIG[:timeout] || 10 ) do 
        result = HTTParty.send( "#{method}", rundeck( options[:uri] ), 
          :headers => { 
            'X-Rundeck-Auth-Token' => CONFIG['api_token'],
            'Accept'               => CONFIG[:accepts]
          },
          :query  => options[:body]
        )
      end
      raise Exception, "unable to retrive the request: #{url}"                        unless result
      raise Exception, "invalid response to request: #{url}, error: #{result.body}"   unless result.code == 200
      ( options[:parse] ) ? parse_xml( result.body ) : result.body
    end

    def parse_xml document
      XmlSimple.xml_in( document )
    end

    def rundeck uri
      '%s/%s' % [ CONFIG['rundeck'], uri.gsub( /^\//,'') ]
    end
  end
end
