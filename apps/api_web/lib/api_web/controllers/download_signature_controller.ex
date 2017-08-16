defmodule ApiWeb.DownloadSignatureController do
  use ApiWeb, :controller

  @doc """
  Builds URL and returns to browser to force download
  http://docs.aws.amazon.com/AmazonS3/latest/dev/RESTAuthentication.html#RESTAuthenticationQueryStringAuth
  """
  def request(conn, %{"path" => path}) do
    conn
    |> put_status(:created)
    |> render("show.json", body: sign(path))
  end

  defp sign(path) do
    "https://#{System.get_env("S3_BUCKET_NAME")}.s3.amazonaws.com/#{path}"
    |> add_access_key
    |> add_expiration_time(expires_at)
    |> add_signature(path, expires_at)
  end

  defp add_access_key(url) do
    url <> "?AWSAccessKeyId=" <> System.get_env("AWS_ACCESS_KEY_ID")
  end

  defp add_signature(url, path, expires_at) do
    url <> "?Signature=" <> hmac_sha1(System.get_env("AWS_SECRET_ACCESS_KEY"), string_to_sign(path, expires_at))
  end

  defp add_expiration_time(url, expires_at) do
    url <> "?Expires=#{expires_at}"
  end

  defp now_plus do
    import Timex
    now()
    |> shift(minutes: 60)
    |> DateTime.to_unix
  end

  defp hmac_sha1(secret, msg) do
    :crypto.hmac(:sha, secret, msg)
    |> Base.encode64
  end

  defp string_to_sign(path, expires_at) do
    ["GET", "", "", expires_at, "", "/" <> System.get_env("S3_BUCKET_NAME") <> path] 
    |> Enum.join("\n")
  end

end
