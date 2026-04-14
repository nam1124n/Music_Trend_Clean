defmodule BackendWeb.PageController do
  use BackendWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: ~p"/admin")
  end
end
