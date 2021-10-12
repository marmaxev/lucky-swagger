module LuckySwagger
  module Handlers
    class WebHandler
      include HTTP::Handler
      
      property swagger_files : Array(String)
      property swagger_urls : Array(NamedTuple(name: String, url: String))

      def initialize(@swagger_url : String = "/swagger", @folder : String = "./swagger")
        @static_handler = ::HTTP::StaticFileHandler.new(@folder, fallthrough: false)

        @swagger_files = Dir.entries(@folder).select { |filename| filename.includes?(".yaml") }
        @swagger_urls = @swagger_files.map { |file| {name: file.split('.').first, url: "/#{file}"} }
      end

      def call(context : HTTP::Server::Context)
        if context.request.path == @swagger_url
          context.response.status_code = 200
          context.response.headers["Content-Type"] = "text/html"

          ECR.embed("#{__DIR__}/../views/index.html.ecr", context.response)        
        elsif context.request.path.includes?(".yaml") && File.exists?(@folder + context.request.path)
          @static_handler.call(context)
        else
          call_next(context)
        end
      end
    end
  end
end
