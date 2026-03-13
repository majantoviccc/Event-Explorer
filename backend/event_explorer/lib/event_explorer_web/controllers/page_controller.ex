defmodule EventExplorerWeb.PageController do
  use EventExplorerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
