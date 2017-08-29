defmodule ApiWeb.Router do
  use ApiWeb, :router

  pipeline :api do
    plug :accepts, ["json", "json-api"]
  end

  scope "/api", ApiWeb do
    pipe_through :api

    get "/upload-signature", UploadSignatureController, :create
    get "/upload-image", UploadImageController, only: [:upload]
    post "/download-signature", DownloadSignatureController, :request
  end
end
