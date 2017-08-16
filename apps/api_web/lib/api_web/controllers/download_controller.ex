defmodule ApiWeb.DownloadController do
  use ApiWeb, :controller

  """
  download direct document
  caching a downloaded that doesn't have to go to S3
  """
  def request(conn, %{"filepath" => filepath}) do case HTTPoison.get filepath do
      {:ok, %{status_code: 200, body: body}} -> {:ok, body}
      {:error} -> {:error, :s3_httppoison_error}
    end
  end

end
