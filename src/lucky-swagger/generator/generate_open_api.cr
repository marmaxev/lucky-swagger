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

      File.open(filename, "w") { |file| YAML.dump(LuckySwagger::OpenApiGenerator.generate_open_api, file) }
    end
  end
end
