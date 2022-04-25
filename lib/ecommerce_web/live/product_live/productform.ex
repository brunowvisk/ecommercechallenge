defmodule EcommerceWeb.ProductLive.Productform do
  use EcommerceWeb, :live_view

  alias Ecommerce.Products

  alias Ecommerce.Products
  alias Ecommerce.Products.Product

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Products.subscribe()

    products = Products.list_products()

    changeset = Products.change_product(%Product{})

    socket =
      assign(socket,
        products: products,
        changeset: changeset
      )

    socket =
      allow_upload(
        socket,
        :photo,
        accept: ~w(.png .jpeg .jpg),
        max_entries: 3,
        max_file_size: 10_000_000
      )

    {:ok, socket, temporary_assigns: [products: []]}
  end

  def handle_event("validate", %{"product" => product_params}, socket) do
    changeset =
      %Product{}
      |> Products.change_product(product_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    {completed, []} = uploaded_entries(socket, :photo)

    urls =
      for entry <- completed do
        Routes.static_path(socket, "/uploads/#{filename(entry)}")
      end

    product = %Product{media: urls}

    case Products.create_product(product, product_params, &consume_photos(socket, &1)) do
      {:ok, _product} ->
        changeset = Products.change_product(%Product{})
        {:noreply, assign(socket, changeset: changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end

    socket
    |> put_flash(:info, "Produto cadastrado com sucesso!")
    |> push_redirect(to: "/products")
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Products.get_product!(id)
    {:ok, _} = Products.delete_product(product)

    {:noreply, assign(socket, :products, list_products())}
  end

  defp list_products do
    Products.list_products()
  end

  @impl true
  def handle_info({:product_created, product}, socket) do
    {:noreply,
     update(socket, :products, fn products ->
       [product | products]
     end)}
  end

  def handle_event("cancel", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}
  end

  defp consume_photos(socket, product) do
    consume_uploaded_entries(socket, :photo, fn meta, entry ->
      destPath = Path.join("priv/static/uploads", filename(entry))
      File.cp!(meta.path, destPath)
    end)

    {:ok, product}
  end

  defp filename(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    "#{entry.uuid}.#{ext}"
  end
end
