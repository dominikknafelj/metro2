defmodule Metro2.Segment do
  @moduledoc """
  This module defines the to_metro method for header-, base-, tailer- and appended segments,
  and helpers to read formatted field values and collect field errors.
  """
  alias Metro2.Fields
  alias Metro2.Records.BaseSegment

  @doc false
  # this function returns the segment as a single metro2 record line. Base segments get their
  # appended segments written after the fixed part, and the record descriptor word set to
  # the total record length. Raises ArgumentError naming the first invalid field.
  def to_metro2(%BaseSegment{} = segment) do
    fixed =
      segment
      |> Fields.put(:record_descriptor_word, BaseSegment.record_length(segment))
      |> fixed_to_metro2()

    [fixed | Enum.map(BaseSegment.appendages(segment), &fixed_to_metro2/1)]
    |> IO.iodata_to_binary()
  end

  def to_metro2(segment), do: fixed_to_metro2(segment)

  # concatenates the fields in the order declared by the segment module's fields/0
  defp fixed_to_metro2(%module{} = segment) do
    Enum.map_join(module.fields(), fn field ->
      case Fields.format(Map.fetch!(segment, field)) do
        {:ok, formatted} -> formatted
        {:error, message} -> raise ArgumentError, message: "#{field}: #{message}"
      end
    end)
  end

  @doc false
  # returns [{field, message}] for every field of the segment which can't be formatted
  def field_errors(%module{} = segment) do
    for field <- module.fields(),
        {:error, message} <- [Fields.format(Map.fetch!(segment, field))],
        do: {field, message}
  end

  @doc false
  # returns the formatted, trimmed value of a field, or nil when it is blank or invalid
  def value(segment, field) do
    case Fields.format(Map.fetch!(segment, field)) do
      {:ok, formatted} ->
        case String.trim(formatted) do
          "" -> nil
          trimmed -> trimmed
        end

      {:error, _} ->
        nil
    end
  end

  @doc false
  # true when a numeric or date field holds a non-zero value
  def present?(segment, field) do
    case value(segment, field) do
      nil -> false
      formatted -> String.trim(formatted, "0") != ""
    end
  end
end
