defmodule ApiWeb.UploadSignatureController do
  use ApiWeb, :controller

  @doc """
  All we are doing is giving the frontend a signed url to allow the browser to complete a direct upload
  """
  def create(conn, %{"filename" => filename, "mimetype" => mimetype}) do
    conn
    |> put_status(:created)
    |> render("create.json", signature: sign(filename, mimetype))
  end

  defp sign(filename, mimetype) do
    policy = policy(filename, mimetype)

    %{
      key: filename,
      'Content-Type': mimetype,
      acl: "public-read",
      success_action_status: "201",
      action: "https://s3.amazonaws.com/#{System.get_env("S3_BUCKET_NAME")}",
      'AWSAccessKeyId': System.get_env("AWS_ACCESS_KEY_ID"),
      policy: policy,
      signature: hmac_sha1(System.get_env("AWS_SECRET_ACCESS_KEY"), policy)
    }
  end

  defp now_plus(minutes) do
    import Timex
    now
    |> shift(minutes: minutes)
    |> format!("{ISO:Extended:Z}")
  end

  defp hmac_sha1(secret, msg) do
    :crypto.hmac(:sha, secret, msg)
    |> Base.encode64
  end

  defp policy(key, mimetype, expiration_window \\ 60) do
    %{
      # This policy is valid for an hour
      expiration: now_plus(expiration_window),
      conditions: [
        # You can only upload to the bucket we specify.
        %{bucket: System.get_env("S3_BUCKET_NAME")},
        # The uploaded file must be publicly readable. TODO private w/ signed url...maybe with arc
        %{acl: "public-read"},
        ["starts-with", "$Content-Type", mimetype],
        ["starts-with", "$key", key],
        # When things work out ok, AWS should send a 201 response.
        %{success_action_status: "201"}
      ]
    }
    # make this into JSON.
    |> Poison.encode!
    |> Base.encode64
  end

end
