defmodule Ecommerce.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string
      add :description, :string
      add :status, :string
      add :category, :string
      add :media, {:array, :string}, null: false, default: []
      add :price, :float
      add :tags, :string

      timestamps()
    end
  end
end
