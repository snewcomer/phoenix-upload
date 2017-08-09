defmodule ApiWeb.UploadSignatureView do
  use ApiWeb, :view

  def render("create.json", %{signature: signature}) do
    signature
  end
end
