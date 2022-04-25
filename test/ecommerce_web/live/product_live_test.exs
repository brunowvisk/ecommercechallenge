defmodule EcommerceWeb.ProductLiveTest do
  use EcommerceWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ecommerce.ProductsFixtures

  @create_attrs %{
    title: "some title",
    description: "some description",
    price: 50.0,
    status: "Ativo"
  }

  @invalid_attrs %{
    status: "some text",
    price: "some text"
  }

  defp create_product(_) do
    product = product_fixture()
    %{product: product}
  end

  describe "Index" do
    setup [:create_product]

    # test "lists all products", %{conn: conn, product: product} do
    #   {:ok, _index_live, html} = live(conn, Routes.product_index_path(conn, :index))

    #   assert html =~ "Listing Products"
    #   # assert html =~ "product.title"
    # end

    test "renders form title", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, "/productform")

      assert html =~ "Create Product"
      assert html =~ "product.title"
    end

    test "2 - saves new product", %{conn: conn} do
      {:ok, productform_live, _html} = live(conn, "/productform")

      assert productform_live
             |> form("#product-form", product: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        productform_live
        |> form("#product-form", product: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, "/productform")

      assert html =~ ""
      assert html =~ ""
    end

    test "validates title", %{conn: conn} do
      {:ok, productform_live, _html} = live(conn, "/productform")

      assert productform_live
             |> form("#productform", product: %{title: "some title"})
             |> render_change() =~ "Deve ter no mínimo 3 e máximo 20 caracteres"
    end

    test "validates description", %{conn: conn} do
      {:ok, productform_live, _html} = live(conn, "/productform")

      assert productform_live
             |> form("#product_form", product: %{description: "some description"})
             |> render_change() =~ "Deve ter no mínimo 4 e máximo 100 caracteres"
    end

    test "deletes product in listing", %{conn: conn, product: product} do
      {:ok, index_live, _html} = live(conn, Routes.product_index_path(conn, :index))

      assert index_live |> element("#product-#{product.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#product-#{product.id}")
    end
  end
end
