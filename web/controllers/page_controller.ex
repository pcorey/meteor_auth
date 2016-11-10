defmodule MeteorAuth.PageController do
  use MeteorAuth.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
