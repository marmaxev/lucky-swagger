module LuckySwagger
  class OpenApiGenerator
    def self.generate_open_api
      routes = Lucky.router.routes.select { |route| route[1].to_s.includes?("api") }
      paths = if routes.any?
        result = generate_route_description routes.first
        routes.each { |route| result.merge! generate_route_description(route) }

        result
      end

      {
        openapi: "3.0.0",
        info: {
          title: "API",
          description: "API for Lucky project",
          version: "1.0.0"
        },
        paths: paths
      }
    end

    private def self.generate_route_description(route : Tuple(Symbol, String, Lucky::Action.class))
      action_path = route[2].name.split("::")

      {
        format_route_url(route[1]) => {
          route[0] => {
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

    private def self.generate_params_description(route : Tuple(Symbol, String, Lucky::Action.class))
      path_params = route[1].scan(/:\w+/).map do |param|
        {
          name: param[0].delete(':'),
          in: "path",
          description: "",
          required: true,
          schema: {
            type: ""
          }
        }
      end

      query_params = route[2].query_param_declarations.map do |param|
        name = param.split(" : ").first
        type = param.split(" : ").last

        {
          name: name,
          in: "query",
          description: "",
          required: !type.includes?("::Nil"),
          schema: {
            type: type.includes?("::Nil") ? type.sub(" | ::Nil", "") : type
          }
        }
      end

      path_params + query_params
    end

    private def self.format_route_url(url : String) : String
      url.gsub(/:\w+/) { |param| "{#{param.delete(':')}}" }
    end
  end
end
