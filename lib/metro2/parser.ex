defmodule Metro2.Parser do
  @moduledoc """
  Parses METRO 2 character format (426-character, one record per line) content back into a
  `Metro2.File`, including appended segments (J1, J2, K1-K4, L1, N1) on base records.

  Alphanumeric values are returned as written (upper case, trailing blanks removed; blank
  fields become `nil`), numeric and monetary values as integers, dates as `Date` and
  timestamps as `NaiveDateTime`. The file's tailer is parsed too, but `Metro2.File.serialize/1`
  recomputes it from the base segments.
  """
  alias Metro2.Fields
  alias Metro2.Records.BaseSegment
  alias Metro2.Records.HeaderSegment
  alias Metro2.Records.TailerSegment

  @doc """
  Parses METRO 2 content. Returns `{:ok, %Metro2.File{}}` or `{:error, message}` naming the
  line and field that could not be parsed.
  """
  def parse(content) when is_binary(content) do
    content
    |> String.split(["\r\n", "\n"], trim: true)
    |> Enum.with_index(1)
    |> Enum.reduce_while({:ok, Metro2.File.new(), false}, fn {line, number}, {:ok, file, _} ->
      case parse_line(line, file) do
        {:ok, file, tailer?} -> {:cont, {:ok, file, tailer?}}
        {:error, message} -> {:halt, {:error, "line #{number}: #{message}"}}
      end
    end)
    |> case do
      {:ok, _file, false} -> {:error, "missing TRAILER record"}
      {:ok, file, true} -> {:ok, file}
      error -> error
    end
  end

  @doc """
  Like `parse/1`, but raises `ArgumentError` on invalid content.
  """
  def parse!(content) do
    case parse(content) do
      {:ok, file} -> file
      {:error, message} -> raise ArgumentError, message: message
    end
  end

  defp parse_line(<<_rdw::binary-4, "HEADER", _::binary>> = line, file) do
    with {:ok, header, _rest} <- parse_segment(HeaderSegment.new(), line) do
      {:ok, %{file | header: header}, false}
    end
  end

  defp parse_line(<<_rdw::binary-4, "TRAILER", _::binary>> = line, file) do
    with {:ok, tailer, _rest} <- parse_segment(TailerSegment.new(), line) do
      {:ok, %{file | tailer: tailer}, true}
    end
  end

  defp parse_line(line, file) do
    with :ok <- check_ascii(line),
         {:ok, base, rest} <- parse_segment(BaseSegment.new(), line),
         {:ok, base} <- parse_appendages(base, rest),
         :ok <- check_record_length(base, line) do
      {:ok, Metro2.File.add_base_segment(file, base), false}
    end
  end

  defp parse_appendages(base, ""), do: {:ok, base}

  defp parse_appendages(base, <<segment_id::binary-2, _::binary>> = rest) do
    case BaseSegment.appendage_module(segment_id) do
      nil ->
        {:error, "unknown segment identifier #{inspect(segment_id)}"}

      module ->
        with {:ok, segment, rest} <- parse_segment(module.new(), rest) do
          base |> BaseSegment.add_segment(segment) |> parse_appendages(rest)
        end
    end
  end

  defp parse_appendages(_base, rest), do: {:error, "trailing characters #{inspect(rest)}"}

  defp check_record_length(base, line) do
    expected = Fields.get(base, :record_descriptor_word)

    if expected == byte_size(line) do
      :ok
    else
      {:error,
       "record descriptor word is #{expected} but the record has #{byte_size(line)} characters"}
    end
  end

  defp check_ascii(line) do
    if line =~ ~r/\A[\x20-\x7E]*\z/, do: :ok, else: {:error, "contains non-ASCII characters"}
  end

  # fills the fields of a template segment from the start of raw, returning the rest
  defp parse_segment(%module{} = template, raw) do
    Enum.reduce_while(module.fields(), {:ok, template, raw}, fn field, {:ok, segment, rest} ->
      field_struct = Map.fetch!(segment, field)
      width = Fields.width(field_struct)

      with <<chunk::binary-size(width), rest::binary>> <- rest,
           {:ok, parsed} <- Fields.parse(field_struct, chunk) do
        {:cont, {:ok, Map.put(segment, field, parsed), rest}}
      else
        {:error, message} -> {:halt, {:error, "#{field}: #{message}"}}
        _ -> {:halt, {:error, "record too short to contain #{field}"}}
      end
    end)
  end
end
