defmodule ApiWeb.DownloadSignatureController do
  use ApiWeb, :controller

  def request(conn, %{"filepath" => filepath}) do
    case HTTPoison.get filepath do
      {:ok, %{status_code: 200, body: body}} -> {:ok, body}
      {:error} -> {:error, :s3_httppoison_error}
    end
  end

end
