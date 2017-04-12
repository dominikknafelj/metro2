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
      Timex.format!(field.value, "%m%d%Y", :strftime)
      |> Metro2.Base.numeric_to_metro2(8, false)
    end
  end

  defmodule TimeStamp do
    defstruct [:value]

    def to_metro2(field) do
      Timex.format!(field.value, "%m%d%Y%H%M%S", :strftime)
      |> Metro2.Base.numeric_to_metro2(14, false)
    end
  end
end
