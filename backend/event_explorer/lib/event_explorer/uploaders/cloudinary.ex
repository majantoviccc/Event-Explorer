defmodule EventExplorer.Uploaders.Cloudinary do
  @moduledoc """
  Handles image upload, deletion, and URL parsing using Cloudinary.
  """

  @doc "Uploads an image to Cloudinary."
  @spec upload_image(String.t()) ::
          {:ok, %{url: String.t(), public_id: String.t()}} | {:error, any()}
  def upload_image(path) do
    case Cloudex.upload(path) do
      {:ok, response} ->
        {:ok,
         %{
           url: response.secure_url,
           public_id: response.public_id
         }}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc "Deletes an image from Cloudinary by public_id."
  @spec delete_image(String.t()) ::
          {:ok, any()} | {:error, any()}
  def delete_image(public_id) do
    Cloudex.delete(public_id)
  end

  @doc "Extracts public_id from a Cloudinary image URL."
  @spec extract_public_id(String.t()) :: String.t()
  def extract_public_id(url) do
    url
    |> String.split("/upload/")
    |> List.last()
    |> String.split("/")
    |> List.last()
    |> String.split(".")
    |> List.first()
  end
end
