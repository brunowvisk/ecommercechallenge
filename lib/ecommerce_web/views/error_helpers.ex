defmodule EcommerceWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field, class \\ [class: "invalid-feedback"]) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:span, translate_error(error),
        class: Keyword.get(class, :class),
        phx_feedback_for: input_name(form, field)
      )
    end)
  end

  def error_ring(f, field) do
    with :validate <- f.source.action do
      case Keyword.fetch(f.errors, field) do
        {:ok, _} ->
          "border-2 border-red-700 rounded focus:border-red-700 w-full focus: ring-red-700"

        :error ->
          "border-2 border-indigo-500
          rounded focus:border-indigo-500 w-full focus: ring-indigo-500"
      end
    else
      _ ->
        " w-full
        focus: flex-1 block w-full rounded sm:text-sm"
    end
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(EcommerceWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(EcommerceWeb.Gettext, "errors", msg, opts)
    end
  end
end
