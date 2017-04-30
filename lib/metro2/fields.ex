defmodule Metro2.Fields do
  use Timex
  @moduledoc """
  This module defines all the field structs, which can be part of the segments.
  Further it contains methods to get or set values in the field stucts, which are abracting the access to the diskrete values.
  """
  defmodule Alphanumeric do
    @moduledoc false
    # this module defines the alphanumeric field struct
    defstruct [:value, :required_length, permitted_chars: Metro2.Base.alphanumeric]

    @doc false
    def to_metro2(field) do
      Metro2.Base.alphanumeric_to_metro2(field.value, field.required_length, field.permitted_chars)
    end
  end

  defmodule Numeric do
    @moduledoc false
    # this module defines the numeric field struct
    defstruct [:value, :required_length]

    @doc false
    def to_metro2(field) do
      Metro2.Base.numeric_to_metro2(field.value, field.required_length, false)
    end
  end

  defmodule Monetary do
    @moduledoc false
    # this module defines the monetary field struct
    defstruct [:value]

    @doc false
    def to_metro2(field) do
      Metro2.Base.numeric_to_metro2(field.value, 9, true)
    end
  end

  defmodule Date do
    @moduledoc false
    # this module defines the date field struct
    defstruct [:value]

    @doc false
    def to_metro2(field) do
      case field.value do
        nil -> 0
        _ -> Timex.format!(field.value, "%m%d%Y", :strftime)
      end
      |> Metro2.Base.numeric_to_metro2(8, false)
    end
  end

  defmodule TimeStamp do
    @moduledoc false
    # this module defines the timestamp field struct
    defstruct [:value]

    @doc false
    def to_metro2(field) do
      case field.value do
        nil -> 0
        _ -> Timex.format!(field.value, "%m%d%Y%H%M%S", :strftime)
      end
      |> Metro2.Base.numeric_to_metro2(14, false)
    end
  end

  @doc """
  This function sets a new value in the field_struct in the segment struct, addressed by the parent_struct key
  """
  def put(%{} = parent_struct, parent_struct_key, value) do
    field = case Map.get(parent_struct, parent_struct_key) do
              x when is_map(x) -> Map.put(x, :value, value)
              _ -> raise ArgumentError, message: "Field #{parent_struct_key} couldn't be found or is not a map." 
            end
    Map.put(parent_struct, parent_struct_key, field)
  end

  @doc """
  This function gets the value in the field_struct in the segment struct, addressed by the parent_struct key
  """
  def get(%{} = parent_struct, parent_struct_key) do
    case Map.get(parent_struct, parent_struct_key) do
      x when is_map(x) -> Map.get(x, :value)
      _ -> raise ArgumentError, message: "Field #{parent_struct_key} couldn't be found or is not a map." 
    end
  end

  @doc false
  # this function calls the to_metro2 method of the corresponding Module of the field struct
  def to_metro2(%{} = field_struct ) do
    field_struct.__struct__
    |> apply(:to_metro2, [field_struct])
  end
end
