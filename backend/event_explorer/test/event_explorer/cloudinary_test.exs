defmodule EventExplorer.CloudinaryTest do
  use ExUnit.Case

  alias EventExplorer.Uploaders.Cloudinary

  test "upload_image returns error when upload fails" do
    result = Cloudinary.upload_image("invalid_path")

    assert match?({:error, _}, result)
  end

  test "delete_image does not crash" do
    result = Cloudinary.delete_image("invalid_id")

    assert match?({:ok, _}, result) or match?({:error, _}, result)
  end

  test "extract_public_id extracts id from url" do
    url = "https://res.cloudinary.com/demo/image/upload/v12345/yoga-festival_xdbiuq.png"

    result = Cloudinary.extract_public_id(url)

    assert result == "yoga-festival_xdbiuq"
  end
end
