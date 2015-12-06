require 'pathname'
require 'rack'
require 'rack/methodoverride'
require 'rack/protection'

require 'flipper'
require 'flipper/middleware/memoizer'

require 'flipper/ui/actor'
require 'flipper/ui/middleware'

module Flipper
  module UI
    class << self
      # Public: If you set this, the UI will always have a first breadcrumb that
      # says "App" which points to this href. The href can be a path (ie: "/")
      # or full url ("https://app.example.com/").
      attr_accessor :application_breadcrumb_href
    end

    def self.root
      @root ||= Pathname(__FILE__).dirname.expand_path.join('ui')
    end

    def self.app(flipper, options = {})
      app = lambda { |env| [200, {'Content-Type' => 'text/html'}, ['']] }
      builder = Rack::Builder.new
      yield builder if block_given?
      builder.use Rack::Protection
      builder.use Rack::Protection::AuthenticityToken
      builder.use Rack::MethodOverride
      builder.use Flipper::Middleware::Memoizer, flipper
      builder.use Middleware, flipper
      builder.run app
      builder
    end
  end
end
