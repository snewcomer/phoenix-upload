defmodule ApiWeb.Router do
  use ApiWeb, :router

  pipeline :api do
    plug :accepts, ["json", "json-api"]
  end

  scope "/api", ApiWeb do
    pipe_through :api

    post "/upload-signature", UploadSignatureController, :create
    post "/download-signature", DownloadSignatureController, :request
  end
end
