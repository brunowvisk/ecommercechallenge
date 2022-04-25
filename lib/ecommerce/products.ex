defmodule Ecommerce.Products do
  @moduledoc """
    Neste módulo são definidos as principais funções do CRUD, ou seja,
    Create, Read, Update e Delete.
  """

  import Ecto.Query, warn: false
  alias Ecommerce.Repo

  alias Ecommerce.Products.Product

  @doc """
  O list_products retorna todos os produtos existentes no banco de dados.
  Ainda nesta função, foi definido que se retorno seria descendente,
  a partir da coluna inserted_at, ou seja, a partir da última entrada até a primeira.

  """
  def list_products do
    query = from p in Product, order_by: [desc: p.inserted_at]
    Repo.all(query)
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id)

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(%Product{} = product, attrs \\ %{}, func) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
    |> after_save(func)
    |> broadcast(:product_created)
  end

  defp after_save({:ok, product}, func) do
    {:ok, _product} = func.(product)
  end

  defp after_save(error, _func), do: error

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Ecommerce.PubSub, "products")
  end

  defp broadcast({:ok, product}, event) do
    Phoenix.SubPub.broadcast(
      Ecommerce.PubSub,
      "products",
      {event, product}
    )

    {:ok, product}
  end

  defp broadcast({:error, _changeset} = error, _event), do: error
end
