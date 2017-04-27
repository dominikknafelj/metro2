defmodule Metro2.Fields do
  use Timex

  defmodule Alphanumeric do
    defstruct [:value, :required_length, permitted_chars: Metro2.Base.alphanumeric]

    def to_metro2(field) do
      Metro2.Base.alphanumeric_to_metro2(field.value, field.required_length, field.permitted_chars)
    end
  end

  defmodule Numeric do
    defstruct [:value, :required_length]

    def to_metro2(field) do
      Metro2.Base.numeric_to_metro2(field.value, field.required_length, false)
    end
  end

  defmodule Monetary do
    defstruct [:value]

    def to_metro2(field) do
      Metro2.Base.numeric_to_metro2(field.value, 9, true)
    end
  end

  defmodule Date do
    defstruct [:value]

    def to_metro2(field) do
      case field.value do
        nil -> 0
        _ -> Timex.format!(field.value, "%m%d%Y", :strftime)
      end
      |> Metro2.Base.numeric_to_metro2(8, false)
    end
  end

  defmodule TimeStamp do
    defstruct [:value]

    def to_metro2(field) do
      case field.value do
        nil -> 0
        _ -> Timex.format!(field.value, "%m%d%Y%H%M%S", :strftime)
      end
      |> Metro2.Base.numeric_to_metro2(14, false)
    end
  end

  def put(%{} = parent_struct, parent_struct_key, value) do
    field = case Map.get(parent_struct, parent_struct_key) do
              x when is_map(x) -> Map.put(x, :value, value)
              _ -> raise ArgumentError, message: "Field #{parent_struct_key} couldn't be found or is not a map." 
            end
    Map.put(parent_struct, parent_struct_key, field)
  end

  def get(%{} = parent_struct, parent_struct_key) do
    case Map.get(parent_struct, parent_struct_key) do
      x when is_map(x) -> Map.get(x, :value)
      _ -> raise ArgumentError, message: "Field #{parent_struct_key} couldn't be found or is not a map." 
    end
  end

  def to_metro2(%{} = field_struct ) do
    field_struct.__struct__
    |> apply(:to_metro2, [field_struct])
  end
end
