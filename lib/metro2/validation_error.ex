defmodule Metro2.ValidationError do
  @moduledoc """
  Raised by `Metro2.File.serialize/1` and `Metro2.File.stream/2` when records are invalid.

  `errors` is a list of maps with the keys:

    * `:record` - `:header` or `{:base, n}` (1-based, in insertion order)
    * `:segment` - `:header`, `:base`, `:j1`, `:j2`, `:k1` ... `:n1`
    * `:field` - the field name
    * `:message` - what is wrong
  """
  defexception errors: []

  @shown 20

  @impl true
  def message(%{errors: errors}) do
    lines = errors |> Enum.take(@shown) |> Enum.map(&format/1)
    more = if length(errors) > @shown, do: ["... and #{length(errors) - @shown} more"], else: []

    Enum.join(["#{length(errors)} invalid field(s) in METRO 2 file:" | lines ++ more], "\n  ")
  end

  defp format(%{record: record, segment: segment, field: field, message: message}) do
    "#{record_label(record)}#{segment_label(segment)} #{field}: #{message}"
  end

  defp record_label(:header), do: "header"
  defp record_label({:base, index}), do: "base record #{index}"

  defp segment_label(segment) when segment in [:header, :base], do: ""
  defp segment_label(segment), do: " #{segment |> Atom.to_string() |> String.upcase()} segment"
end
