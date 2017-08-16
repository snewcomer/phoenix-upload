defmodule ApiWeb.DownloadSignatureControllerTest do
  use ApiWeb.ConnCase

  test "POST to download signed url", %{conn: conn} do
    path = "/probablyacat.jpg"

    conn =
      post conn, download_signature_path(conn, :request), %{ path: path }

    response = json_response(conn, 201)
    assert response =~ path
    assert response =~ "s3.amazonaws.com"
    assert response =~ "?Expires="
    assert response =~ "?Signature="
    assert response =~ "?AWSAccessKeyId="
  end
end
