defmodule Ecommerce.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @doc """
    @fields_that_can_be_changed são os campos que podem ser alterados, ou seja,
    que podem receber valores e alterações através de bindings introduzidos
    pelo usuário no formulário disponibilizado ao cliente, neste caso,
    no componente: productform.html.
    @required_fields é utilizado para definir os campos obrigatórios e que
    será informado quando da criação do pipe validate_required.
    Schema define a fonte de dados que será fornecido em uma struct.
    Neste caso específico, está definindo quais os campos que integrarão
    um produto criado.
  """
  @fields_that_can_be_changed [
    :title,
    :description,
    :status,
    :category,
    :media,
    :price,
    :tags
  ]

  @required_fields [
    :title,
    :description,
    :status,
    :price
  ]

  @primary_key {:id, :binary_id, autogenerate: true}

  @derive {Jason.Encoder,
           only: [:id, :title, :description, :status, :category, :media, :price, :tags]}

  schema "products" do
    field :title, :string
    field :description, :string
    field :status, :string
    field :category, :string
    field :media, {:array, :string}, default: []
    field :price, :float
    field :tags, :string

    timestamps()
  end

  @doc """
    changeset é responsável pelas validações da estrutura dos dados passados.
  """
  def changeset(struct \\ %__MODULE__{}, %{} = params) do
    struct
    |> cast(params, @fields_that_can_be_changed)
    |> validate_required(@required_fields)
    |> validate_title()
    |> validate_description()
    |> validate_and_transform_price()
    |> unique_constraint([:title])
  end

  defp validate_title(changeset) do
    changeset
    |> validate_length(:title,
      min: 3,
      max: 20,
      message: "Deve ter no mínimo 3 e máximo 20 caracteres"
    )
  end

  defp validate_description(changeset) do
    changeset
    |> validate_length(:description,
      min: 4,
      max: 100,
      message: "Deve ter no mínimo 4 e máximo 100 caracteres"
    )
  end

  defp validate_and_transform_price(changeset) do
    changeset
    |> validate_number(:price,
      greater_than: 0,
      message: "Formato inválido!"
    )
    |> IO.inspect()
  end
end
