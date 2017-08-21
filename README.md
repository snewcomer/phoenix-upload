# Api.Umbrella

### Two Routes
1. `upload-signature`
  `@spec create(conn, %{ "filename" => filename, "mimetype" => mimetype } = map) :: map`
2. `download-signature`
  `@spec request(conn, %{ "filepath" => filepath } = map) :: String.t`

### In progress
* Async file downloads
