defmodule ApiWeb.UploadImageController do
  use ApiWeb, :controller

  import SweetXml
  alias ExAws.S3

  @doc """
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

    {:ok, response} =
      S3.put_object("image_bucket", filename, image_binary)
      |> ExAws.request()

    # Return the URL to the file on S3
    response.body
    |> SweetXml.xpath(~x"//Location/text()")
    |> to_string()
  end

  defp unique_filename(extension) do
    UUID.uuid4(:hex) <> extension
  end

  defp image_extension(<<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, _::binary>>), do: ".png"
  defp image_extension(<<0xff, 0xD8, _::binary>>), do: ".jpg"

end
