defmodule EcommerceWeb.ProductLive.Index do
  use EcommerceWeb, :live_view

  alias Ecommerce.Products

  alias Ecommerce.Products
  alias Ecommerce.Products.Product

  @impl true
  def mount(_params, _session, socket) do
    products = Products.list_products()

    {:ok,
     assign(socket,
       products: products,
       editing: %{
         id: 0,
         title: "",
         description: "",
         status: "",
         category: "",
         media: "",
         price: "",
         tags: ""
       },
       toggle_ids: []
     )}
  end

  defp get_product_by_id(products, id) do
    Enum.find(products, fn product -> product.id == String.to_integer(id) end)
  end

  @doc """
   Função para pegar todos os produtos criados.
  """

  # defp get_products(socket) do
  #   socket.assigns.products
  # end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Product")
    |> assign(:product, Products.get_product!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, %Product{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Products")
    |> assign(:product, nil)
  end

  @doc """
  Função para deletar productos selecionados.
  """
  @impl true
  def handle_event("delete", %{}, socket) do
    toggle_ids = socket.assigns.toggle_ids
    products = Enum.reject(socket.assigns.products, &(&1.id in toggle_ids))
    products_delete = Enum.filter(socket.assigns.products, &(&1.id in toggle_ids))

    Task.async(fn ->
      products_delete
      |> Enum.each(&Products.delete_product/1)
    end)

    {
      :noreply,
      socket
      |> assign(:toggle_ids, [])
      |> assign(:products, products)
    }
  end

  defp list_products do
    Products.list_products()
  end

  @doc """
  Função para selecionar ou tirar a seleção de todas as checkboxes.
  """
  def handle_event("toggle-all", %{"value" => "on"}, socket) do
    product_ids = socket.assigns.products |> Enum.map(& &1.id)
    {:noreply, assign(socket, :toggle_ids, product_ids)}
  end

  def handle_event("toggle-all", %{}, socket) do
    {:noreply, assign(socket, :toggle_ids, [])}
  end

  def handle_event("toggle", %{"toggle-id" => id}, socket) do
    id = String.to_integer(id)
    toggle_ids = socket.assigns.toggle_ids

    toggle_ids =
      if id in toggle_ids do
        Enum.reject(toggle_ids, &(&1 == id))
      else
        [id | toggle_ids]
      end

    {:noreply, assign(socket, :toggle_ids, toggle_ids)}
  end

  def handle_event("delete", %{}, socket) do
    toggle_ids = socket.assigns.toggle_ids
    products = Enum.reject(socket.assigns.products, &(&1.id in toggle_ids))
    products_delete = Enum.filter(socket.assigns.products, &(&1.id in toggle_ids))

    Task.async(fn ->
      products_delete
      |> Enum.each(&Products.delete_product/1)
    end)

    {
      :noreply,
      socket
      |> assign(:toggle_ids, [])
      |> assign(:products, products)
    }
  end
end
