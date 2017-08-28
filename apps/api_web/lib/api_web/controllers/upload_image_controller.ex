defmodule ApiWeb.UploadImageController do
  use ApiWeb, :controller

  @doc """
  All we are doing is giving the frontend a signed url to allow the browser to complete a direct upload
  """
  def upload(conn, %{"image" => image_base64}) do
    conn
    |> put_status(:created)
    |> render("create.json", url: upload_image(image_base64))
  end

  @spec upload_image(String.t) :: String.t
  defp upload_image(image_base64) do
    { :ok, image_binary } = Base.decode64(image_base64) 

    filename =
      image_binary
      |> image_extension()
      |> unique_filename()
      |> build_s3_struct(image_binary)
      |> add_bucket_to_params 
      |> add_resource_to_params
      |> ApiWeb.S3.request
  end

  @spec build_s3_struct(filename :: String.t, binary :: String.t) :: Struct
  defp build_s3_struct(filename, binary) do
    bucket = System.get_env("S3_BUCKET_NAME")
    build_struct(:put, bucket, filename, body: binary)
  end

  defp unique_filename(extension) do
    UUID.uuid4(:hex) <> extension
  end

  defp image_extension(<<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, _::binary>>), do: ".png"
  defp image_extension(<<0xff, 0xD8, _::binary>>), do: ".jpg"

  @spec build_struct(http_method :: String.t, bucket :: String.t, path :: String.t, data :: String.t, opts :: map) :: Struct 
  defp build_struct(http_method, bucket, path, data \\ [], opts \\ %{}) do
    %ApiWeb.S3{
      http_method: http_method,
      bucket: bucket,
      path: path,
      body: data[:body] || "",
      headers: data[:headers] || %{},
      resource: data[:resource] || "",
      params: data[:params] || %{}
    } |> struct(opts)
  end

  defp add_bucket_to_params(str) do
    path = "/#{str.bucket}/#{str.path}" |> String.trim_leading("//")
    str |> Map.put(:path, path)
  end

  defp add_resource_to_params(str) do
    params = str.params |> Map.new |> Map.put(str.resource, 1)
    str |> Map.put(:params, params)
  end

  # @headers [:cache_control, :content_disposition, :content_encoding, :content_length, :content_type,
  #   :expect, :expires, :content_md5]
  # @amz_headers [:storage_class, :website_redirect_location]
  # def put_object_headers(opts) do
  #   opts = opts |> Map.new

  #   regular_headers = 
  #     opts
  #     |> format_and_take(@headers)

  #   amz_headers = 
  #     opts
  #     |> format_and_take(@amz_headers)
  #     |> namespace("x-amz")

  #   acl_headers = format_acl_headers(opts)

  #   ## http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingServerSideEncryption.html
  #   # encryption_headers = 
  #   #   opts
  #   #   |> Map.get(:encryption, %{})
  #   #   |> build_encryption_headers

  #   # meta = 
  #   #   opts
  #   #   |> Map.get(:meta, [])
  #   #   |> build_meta_headers

  #   regular_headers
  #   |> Map.merge(amz_headers)
  #   |> Map.merge(acl_headers)
  #   # |> Map.merge(encryption_headers)
  #   # |> Map.merge(meta)

  # end

  # def build_meta_headers(meta) do
  #   Enum.into(meta, %{}, fn {k ,v} ->
  #     {"x-amz-meta-#{k}", v}
  #   end)
  # end

  # @doc """
  # format_and_take %{param_one: "v1", param_two: "v2"}, [:param_one]
  # #=> %{"param-one" => "v1"}
  # """
  # def format_and_take(%{} = opts, param_list) do
  #   param_list
  #   |> Enum.map(&{&1, normalize_param(&1)})
  #   |> Enum.reduce(%{}, fn({elixir_opt, aws_opt}, params) ->
  #     case Map.fetch(opts, elixir_opt) do
  #       :error       -> params
  #       {:ok, nil}   -> params
  #       {:ok, value} -> Map.put(params, aws_opt, value)
  #     end
  #   end)
  # end

  # def format_and_take(opts, param_list) do
  #   opts
  #   |> Map.new
  #   |> format_and_take(param_list)
  # end

  # @acl_headers [:acl, :grant_read, :grant_write, :grant_read_acp, :grant_write_acp, :grant_full_control]
  # def format_acl_headers(%{acl: canned_acl}) do
  #   %{"x-amz-acl" => normalize_param(canned_acl)}
  # end
  # def format_acl_headers(grants), do: format_grant_headers(grants)

  # defp namespace(list, value) do
  #   list
  #   |> Enum.map(fn {k,v} -> {"#value}-#{k}", v} end)
  #   |> Map.new
  # end
end
