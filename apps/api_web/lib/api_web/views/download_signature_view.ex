defmodule ApiWeb.DownloadSignatureView do
  use ApiWeb, :view

  def render("show.json", %{body: body}) do
    body
  end
end
