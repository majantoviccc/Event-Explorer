defmodule EventExplorer.Uploaders.Cloudinary do
  def upload_image(path) do
    case Cloudex.upload(path) do
      {:ok, response} ->
        {:ok, response.secure_url}

      {:error, error} ->
        {:error, error}
    end
  end
end
