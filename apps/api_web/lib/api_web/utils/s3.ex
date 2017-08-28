defmodule ApiWeb.S3 do

  defstruct [
    bucket: "",
    path: "/",
    http_method: nil,
    body: "",
    resource: "",
    params: %{},
    headers: %{},
    service: :s3
  ]

  @default_opts [recv_timeout: 30_000]

  def request(%{ http_method: method, path: url, body: body, headers: headers } = s3_struct) do
    case :hackney.request(method, url, headers, body, @default_opts) do
      {:ok, status, headers} ->
        {:ok, %{status_code: status, headers: headers}}
      {:ok, status, headers, body} ->
        {:ok, %{status_code: status, headers: headers, body: body}}
      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end

end
