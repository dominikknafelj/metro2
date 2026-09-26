defmodule Metro2.Fields do
  @moduledoc """
  This module defines all the field structs, which can be part of the segments.
  Further it contains methods to get or set values in the field structs, which abstract
  the access to the discrete values.

  Every field type implements `format/1` (returning `{:ok, string}` or `{:error, message}`),
  `width/1` and `parse/2`.
  """
  alias Metro2.Base

  defmodule Alphanumeric do
    @moduledoc false
    # this module defines the alphanumeric field struct.
    # strip_chars: characters removed before validation (e.g. apostrophes in names)
    # codes: humanized atom -> code map, so atoms like :current can be put as values
    # valid_codes: when set, the value must be one of these codes
    defstruct [:value, :required_length, :permitted_chars, :strip_chars, :codes, :valid_codes]

    @doc false
    def to_metro2(field), do: Metro2.Fields.to_metro2(field)

    @doc false
    def format(%__MODULE__{} = field) do
      permitted_chars = field.permitted_chars || Base.alphanumeric()

      with {:ok, value} <- normalize(field.value, field),
           :ok <- check_code(value, field) do
        Base.format_alphanumeric(value, field.required_length, permitted_chars)
      end
    end

    @doc false
    def width(%__MODULE__{required_length: length}), do: length

    @doc false
    def parse(%__MODULE__{} = field, raw) do
      value =
        case String.trim_trailing(raw) do
          "" -> nil
          trimmed -> trimmed
        end

      {:ok, %{field | value: value}}
    end

    @doc """
    Creates an alphanumeric field with standard alphanumeric characters only
    """
    def new(required_length, value \\ nil, opts \\ []) do
      build(required_length, value, Base.alphanumeric(), opts)
    end

    @doc """
    Creates an alphanumeric field that allows alphanumeric characters plus dashes.
    Apostrophes are removed (O'Brien is reported as OBRIEN).
    """
    def new_with_dash(required_length, value \\ nil) do
      build(required_length, value, Base.alphanumeric_plus_dash(), strip: ~r/'/)
    end

    @doc """
    Creates an alphanumeric field that allows alphanumeric characters plus dots, dashes, and
    slashes. Apostrophes, commas and pound signs are removed.
    """
    def new_with_dot_dash_slash(required_length, value \\ nil) do
      build(required_length, value, Base.alphanumeric_plus_dot_dash_slash(), strip: ~r/[',#]/)
    end

    @doc """
    Creates an alphanumeric field backed by a code table of `Metro2.Base` (e.g. `:account_status`).
    Humanized atoms are translated to their code, integers are zero padded to the field length,
    and for closed code lists the value must be a valid code.
    """
    def new_code(required_length, table, value \\ nil) do
      %{
        build(required_length, value, Base.alphanumeric(), [])
        | codes: Base.code_table(table),
          valid_codes: Base.valid_codes(table)
      }
    end

    @doc """
    Creates an alphanumeric field whose value must be one of `valid_codes`.
    """
    def new_enum(required_length, valid_codes, value \\ nil) do
      %{build(required_length, value, Base.alphanumeric(), []) | valid_codes: valid_codes}
    end

    defp build(required_length, value, permitted_chars, opts) do
      %__MODULE__{
        value: value,
        required_length: required_length,
        permitted_chars: permitted_chars,
        strip_chars: Keyword.get(opts, :strip)
      }
    end

    defp normalize(nil, _field), do: {:ok, nil}

    defp normalize(value, %{codes: codes}) when is_atom(value) and is_map(codes) do
      case Map.fetch(codes, value) do
        {:ok, code} -> {:ok, code}
        :error -> {:error, "unknown code #{inspect(value)}"}
      end
    end

    defp normalize(value, %{codes: codes} = field) when is_integer(value) and is_map(codes) do
      {:ok, value |> Integer.to_string() |> String.pad_leading(field.required_length, "0")}
    end

    defp normalize(value, _field) when is_number(value), do: {:ok, value}

    defp normalize(value, field) when is_binary(value) do
      case :unicode.characters_to_nfd_binary(value) do
        decomposed when is_binary(decomposed) ->
          {:ok,
           decomposed
           # drop combining marks, so accented letters become their ASCII base letter
           |> String.replace(~r/\p{Mn}/u, "")
           |> strip(field.strip_chars)
           |> String.replace(~r/ {2,}/, " ")
           |> String.trim(" ")
           |> String.upcase()}

        _ ->
          {:error, "Content (#{inspect(value)}) is not valid UTF-8"}
      end
    end

    defp normalize(value, _field), do: {:error, "Content (#{inspect(value)}) is not a string"}

    defp strip(value, nil), do: value
    defp strip(value, regex), do: String.replace(value, regex, "")

    defp check_code(_value, %{valid_codes: nil}), do: :ok
    defp check_code(value, _field) when value in [nil, ""], do: :ok

    defp check_code(value, %{valid_codes: valid_codes}) do
      if to_string(value) in valid_codes do
        :ok
      else
        {:error,
         "#{inspect(value)} is not a valid code (#{valid_codes |> Enum.sort() |> Enum.join(", ")})"}
      end
    end
  end

  defmodule Numeric do
    @moduledoc false
    # this module defines the numeric field struct.
    # strip_separators: remove dashes, spaces, dots and parentheses from string values
    # (SSNs, telephone numbers) and require the remainder to be digits only.
    defstruct [:value, :required_length, strip_separators: false]

    @doc false
    def to_metro2(field), do: Metro2.Fields.to_metro2(field)

    @doc false
    def format(%__MODULE__{value: value, strip_separators: true} = field) when is_binary(value) do
      digits = String.replace(value, ~r/[\s\-().]/, "")

      if Regex.match?(~r/\A\d*\z/, digits) do
        Base.format_numeric(digits, field.required_length, false)
      else
        {:error, "numeric field (#{value}) may only contain digits and separators"}
      end
    end

    def format(%__MODULE__{} = field) do
      Base.format_numeric(field.value, field.required_length, false)
    end

    @doc false
    def width(%__MODULE__{required_length: length}), do: length

    @doc false
    def parse(%__MODULE__{} = field, raw), do: Metro2.Fields.parse_integer(field, raw)

    @doc """
    Creates a numeric field
    """
    def new(required_length, value \\ nil) do
      %__MODULE__{value: value, required_length: required_length}
    end

    @doc """
    Creates a numeric identifier field (SSN, telephone number) that accepts separators
    like `123-45-6789` or `(555) 123-4567` in string values.
    """
    def new_identifier(required_length, value \\ nil) do
      %__MODULE__{value: value, required_length: required_length, strip_separators: true}
    end
  end

  defmodule Monetary do
    @moduledoc false
    # this module defines the monetary field struct
    defstruct [:value]

    @doc false
    def to_metro2(field), do: Metro2.Fields.to_metro2(field)

    @doc false
    def format(%__MODULE__{value: value}), do: Base.format_numeric(value, 9, true)

    @doc false
    def width(_field), do: 9

    @doc false
    def parse(%__MODULE__{} = field, raw), do: Metro2.Fields.parse_integer(field, raw)

    @doc """
    Creates a monetary field
    """
    def new(value \\ nil) do
      %__MODULE__{value: value}
    end
  end

  defmodule Date do
    @moduledoc false
    # this module defines the date field struct. Values can be Date, DateTime, NaiveDateTime
    # or ISO 8601 strings ("2024-01-31").
    defstruct [:value]

    @doc false
    def to_metro2(field), do: Metro2.Fields.to_metro2(field)

    @doc false
    def format(%__MODULE__{value: nil}), do: {:ok, "00000000"}

    def format(%__MODULE__{value: value}) when is_binary(value) do
      case Elixir.Date.from_iso8601(value) do
        {:ok, date} -> format(%__MODULE__{value: date})
        {:error, _} -> {:error, "invalid date #{inspect(value)} (expected YYYY-MM-DD)"}
      end
    end

    def format(%__MODULE__{value: %{year: _, month: _, day: _} = value}) do
      {:ok, Calendar.strftime(value, "%m%d%Y")}
    end

    def format(%__MODULE__{value: value}), do: {:error, "invalid date #{inspect(value)}"}

    @doc false
    def width(_field), do: 8

    @doc false
    def parse(%__MODULE__{} = field, "00000000"), do: {:ok, %{field | value: nil}}

    def parse(%__MODULE__{} = field, <<mm::binary-2, dd::binary-2, yyyy::binary-4>> = raw) do
      with {:ok, [y, m, d]} <- Metro2.Fields.to_integers([yyyy, mm, dd]),
           {:ok, date} <- Elixir.Date.new(y, m, d) do
        {:ok, %{field | value: date}}
      else
        _ -> {:error, "invalid date #{inspect(raw)}"}
      end
    end

    def parse(_field, raw), do: {:error, "invalid date #{inspect(raw)}"}

    @doc """
    Creates a date field
    """
    def new(value \\ nil) do
      %__MODULE__{value: value}
    end
  end

  defmodule TimeStamp do
    @moduledoc false
    # this module defines the timestamp field struct. Values can be NaiveDateTime, DateTime,
    # Date (midnight) or ISO 8601 strings.
    defstruct [:value]

    @doc false
    def to_metro2(field), do: Metro2.Fields.to_metro2(field)

    @doc false
    def format(%__MODULE__{value: nil}), do: {:ok, "00000000000000"}

    def format(%__MODULE__{value: value}) when is_binary(value) do
      case NaiveDateTime.from_iso8601(value) do
        {:ok, datetime} -> format(%__MODULE__{value: datetime})
        {:error, _} -> {:error, "invalid timestamp #{inspect(value)}"}
      end
    end

    def format(%__MODULE__{value: %{hour: _} = value}) do
      {:ok, Calendar.strftime(value, "%m%d%Y%H%M%S")}
    end

    def format(%__MODULE__{value: %{year: _, month: _, day: _} = value}) do
      {:ok, Calendar.strftime(value, "%m%d%Y") <> "000000"}
    end

    def format(%__MODULE__{value: value}), do: {:error, "invalid timestamp #{inspect(value)}"}

    @doc false
    def width(_field), do: 14

    @doc false
    def parse(%__MODULE__{} = field, "00000000000000"), do: {:ok, %{field | value: nil}}

    def parse(
          %__MODULE__{} = field,
          <<mm::binary-2, dd::binary-2, yyyy::binary-4, h::binary-2, mi::binary-2, s::binary-2>> =
            raw
        ) do
      with {:ok, [y, m, d, h, mi, s]} <- Metro2.Fields.to_integers([yyyy, mm, dd, h, mi, s]),
           {:ok, datetime} <- NaiveDateTime.new(y, m, d, h, mi, s) do
        {:ok, %{field | value: datetime}}
      else
        _ -> {:error, "invalid timestamp #{inspect(raw)}"}
      end
    end

    def parse(_field, raw), do: {:error, "invalid timestamp #{inspect(raw)}"}

    @doc """
    Creates a timestamp field
    """
    def new(value \\ nil) do
      %__MODULE__{value: value}
    end
  end

  @doc """
  This function sets a new value in the field_struct in the segment struct, addressed by the parent_struct key.
  The value is not validated; use `cast/3` to validate while setting.
  """
  def put(%{} = parent_struct, parent_struct_key, value) do
    field =
      case Map.get(parent_struct, parent_struct_key) do
        x when is_map(x) ->
          Map.put(x, :value, value)

        _ ->
          raise ArgumentError,
            message: "Field #{parent_struct_key} couldn't be found or is not a map."
      end

    Map.put(parent_struct, parent_struct_key, field)
  end

  @doc """
  Sets a value like `put/3`, but validates it immediately.
  Returns `{:ok, segment}` or `{:error, message}`.
  """
  def cast(%{} = parent_struct, parent_struct_key, value) do
    segment = put(parent_struct, parent_struct_key, value)

    case format(Map.fetch!(segment, parent_struct_key)) do
      {:ok, _} -> {:ok, segment}
      {:error, message} -> {:error, "#{parent_struct_key}: #{message}"}
    end
  end

  @doc """
  This function gets the value in the field_struct in the segment struct, addressed by the parent_struct key
  """
  def get(%{} = parent_struct, parent_struct_key) do
    case Map.get(parent_struct, parent_struct_key) do
      x when is_map(x) ->
        Map.get(x, :value)

      _ ->
        raise ArgumentError,
          message: "Field #{parent_struct_key} couldn't be found or is not a map."
    end
  end

  @doc """
  Formats a field struct into its metro2 representation.
  Returns `{:ok, string}` or `{:error, message}`.
  """
  def format(%{__struct__: module} = field_struct), do: module.format(field_struct)

  @doc false
  # formats a field struct into its metro2 representation, raising ArgumentError when invalid
  def to_metro2(%{} = field_struct) do
    case format(field_struct) do
      {:ok, formatted} -> formatted
      {:error, message} -> raise ArgumentError, message: message
    end
  end

  @doc false
  def width(%{__struct__: module} = field_struct), do: module.width(field_struct)

  @doc false
  def parse(%{__struct__: module} = field_struct, raw), do: module.parse(field_struct, raw)

  @doc false
  def parse_integer(field, raw) do
    case Integer.parse(raw) do
      {value, ""} -> {:ok, %{field | value: value}}
      _ -> {:error, "invalid number #{inspect(raw)}"}
    end
  end

  @doc false
  def to_integers(strings) do
    Enum.reduce_while(strings, {:ok, []}, fn string, {:ok, acc} ->
      case Integer.parse(string) do
        {value, ""} -> {:cont, {:ok, acc ++ [value]}}
        _ -> {:halt, :error}
      end
    end)
  end
end
