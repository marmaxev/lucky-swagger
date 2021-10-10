# lucky-swagger

This library will help you in adding SwaggerUI to your Lucky project.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     lucky-swagger:
       github: marmaxev/lucky-swagger
   ```

2. Run `shards install`

3. Require lucky-swagger shard

   ```crystal
   require "lucky-swagger"
   ```

## Usage

### Create OpenAPI .yaml file

Run `lucky lucky_swagger.generate_open_api -f ./swagger/api.yaml `

This will create a new file in `./swagger` folder with a description in the OpenAPI format for your project and methods that have `api`  in scopes.

For example,

```yaml
openapi: 3.0.0
info:
  title: API
  description: API for Lucky project
  version: 1.0.0
paths:
  /api/foo/{bar}:
    get:
      tags:
      - api
      summary: Api Foo
      description: Api Foo
      parameters:
      - name: bar
        in: path
        required: true
        schema:
          type: ""
      responses:
        "200":
          description: success
          content:
            application/json:
              examples: ""
  /api/bar:
    get:
      tags:
      - api
      summary: Api Bar
      description: Api Bar
      parameters:
      - name: foo
        in: query
        required: false
        schema:
          type: Bool
      responses:
        "200":
          description: success
          content:
            application/json:
              examples: ""
```

Modify this file according to the OpenAPI format to change the description of the API and methods.

### Swagger UI usage

In your file `./src/app_server.cr` add new handler - `LuckySwagger::Handlers::WebHandler`.

```crystal
class AppServer < Lucky::BaseAppServer
  def middleware : Array(HTTP::Handler)
    [
      ...
      Lucky::LogHandler.new,
      # add new web handler
      LuckySwagger::Handlers::WebHandler.new(
        swagger_url: "/swagger", # url for SwaggerUI
        folder: "./swagger" # folder where yaml files are located
      ), 
      Lucky::ErrorHandler.new(action: Errors::Show),
      ...
    ] of HTTP::Handler
  end
  ...
end
```

Learn about middleware with HTTP::Handlers: https://luckyframework.org/guides/http-and-routing/http-handlers.

**Restart** your server and visit `your-server-address/swagger` to access SwaggerUI for your API.

## Contributing

1. Fork it (<https://github.com/your-github-user/lucky-swagger/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [marmaxev](https://github.com/marmaxev) - creator and maintainer

