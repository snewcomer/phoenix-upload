defmodule ApiWeb.UploadSignatureControllerTest do
  use ApiWeb.ConnCase

  test "POST /", %{conn: conn} do
    filename = "probablyacat.jpg"
    mimetype = "image/jpeg"

    conn =
      # We'll post the filename and mimetype to the backend
      get conn, upload_signature_path(conn, :create), %{ filename: filename, mimetype: mimetype }

    response = json_response(conn, 201)
    credentials = response["credentials"]
    assert credentials["key"] == filename
    assert credentials["Content-Type"] == mimetype
    assert credentials["acl"] == "public-read"
    assert credentials["success_action_status"] == "201"
    assert credentials["AWSAccessKeyId"]
    assert credentials["policy"]
    assert credentials["signature"]
    assert response["url"] =~ "s3.amazonaws.com"
  end
end
