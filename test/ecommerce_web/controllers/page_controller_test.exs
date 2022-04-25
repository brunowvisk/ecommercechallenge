defmodule EcommerceWeb.PageControllerTest do
  use EcommerceWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "DESAFIO E-COMMERCE EM ELIXIR"
  end
end
