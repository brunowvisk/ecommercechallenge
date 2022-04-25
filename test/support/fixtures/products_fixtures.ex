defmodule Ecommerce.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ecommerce.Products` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> Ecommerce.Products.create_product()

    product
  end
end
