require "faraday"

module Idioms
  module Faraday
    
    class RaiseErrors < ::Faraday::Response::Middleware
      def on_complete(env)
        case env[:status]
        when 404
          raise ::Faraday::Error::ResourceNotFound, response_values(env)
        when 407
          # mimic the behavior that we get with proxy requests with HTTPS
          raise ::Faraday::Error::ConnectionFailed, %{407 "Proxy Authentication Required "}
        when 400..599
          error = ERRORS.fetch(status, :UnrecognizedResponse)
          exception = Idioms::HTTP.const_get error
          raise exception.new(env)
        end
      end
      
      def response_values(env)
        { status: env[:status], headers: env[:response_headers], body: env[:body] }
      end
    end
    
  end
end
