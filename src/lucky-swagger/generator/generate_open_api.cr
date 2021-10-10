module LuckySwagger
  class GenerateOpenApi < LuckyTask::Task
    summary "Generate OpenAPI documentation for API routes"

    arg :filename, "File for OpenAPI generation",
      shortcut: "-f",
      optional: true

    def call
      file = filename || "./swagger/api.yaml"

      generate_open_api(file)

      output.puts <<-TEXT
        OpenAPI was generated in a file #{file}
      TEXT
    end

    private def generate_open_api(filename : String)
      path = Path[filename].dirname
      Dir.mkdir_p(path) unless Dir.exists?(path)

      File.open(filename, "w") { |file| YAML.dump(generate_description, file) }
    end

    private def generate_description
      routes = Lucky::Router.routes.select { |route| route.path.to_s.includes?("api") }

      {
        openapi: "3.0.0",
        info: {
          title: "API",
          description: "API for Lucky project",
          version: "1.0.0"
        },
        paths: begin
          result = generate_route_description routes.first
          routes.each { |route| result.merge! generate_route_description(route) }

          result
        end
      }
    end

    private def generate_route_description(route : Lucky::Route)
      action_path = route.action.name.split("::")

      {
        format_route_url(route.path) => {
          route.method => {
            tags: [
              action_path.size > 1 ? action_path[-2] : "default"
            ],
            summary: action_path.join(' '),
            description: action_path.join(' '),
            parameters: generate_params_description(route),
            responses: {
              "200" => {
                description: "success",
                content: {
                  "application/json" => {
                    examples: ""
                  }
                }
              }
            }
          
          }
        }
      }
    end

    private def generate_params_description(route : Lucky::Route)
      path_params = route.path.scan(/:\w+/).map do |param|
        {
          name: param[0].delete(':'),
          in: "path",
          required: true,
          schema: {
            type: ""
          }
        }
      end

      query_params = route.action.query_param_declarations.map do |param|
        name = param.split(" : ").first
        type = param.split(" : ").last

        {
          name: name,
          in: "query",
          required: !type.includes?("::Nil"),
          schema: {
            type: type.includes?("::Nil") ? type.sub(" | ::Nil", "") : type
          }
        }
      end

      path_params + query_params
    end

    private def format_route_url(url : String) : String
      url.gsub(/:\w+/) { |param| "{#{param.delete(':')}}" }
    end
  end
end
