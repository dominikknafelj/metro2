defmodule Metro2.Fields do
  use Timex

  defmodule Alphanumeric do
    defstruct [:name, :value, :required_length, permitted_chars: Metro2.Base.alphanumeric]

    def to_metro2(field) do
      Metro2.Base.alphanumeric_to_metro2(field.value, field.required_length, field.permitted_chars, field.name)
    end
  end

  defmodule Numeric do
    defstruct [:value, :required_length]

    def to_metro2(field) do
      Metro2.Base.numeric_to_metro2(field.value, field.required_length, false)
    end
  end

  defmodule Monetary do
    defstruct [:name, :value]

    def to_metro2(field) do
      Metro2.Base.numeric_to_metro2(field.value, 9, true)
    end
  end

  defmodule Date do
    defstruct [:name, :value]

    def to_metro2(field) do
      Timex.format!(field.value, "%m%d%Y", :strftime)
      |> Metro2.Base.numeric_to_metro2(8, false)
    end
  end

  defmodule TimeStamp do
    defstruct [:name, :value]

    def to_metro2(field) do
      Timex.format!(field.value, "%m%d%Y%H%M%S", :strftime)
      |> Metro2.Base.numeric_to_metro2(14, false)
    end
  end

  #     def alphanumeric_field(name, required_length, permitted_chars = Metro2ALPHANUMERIC)
  #     fields << name
  #
  #     # getter
  #     define_method name do
  #       instance_variable_get("@#{name}")
  #     end
  #
  #     # setter (includes validations)
  #     define_method "#{name}=" do | val |
  #       instance_variable_set("@#{name}", val)
  #     end
  #
  #     # to_metro2
  #     define_method "#{name}_to_metro2" do
  #       val = instance_variable_get("@#{name}")
  #       Metro2.alphanumeric_to_metro2(val, required_length, permitted_chars, name)
  #     end
  #   end
  #
  #   def numeric_field(name, required_length, is_monetary = false)
  #     fields << name
  #
  #     # getter
  #     define_method name do
  #       instance_variable_get("@#{name}")
  #     end
  #
  #     # setter (includes validations)
  #     define_method "#{name}=" do | val |
  #       instance_variable_set("@#{name}", val)
  #     end
  #
  #     # to_metro2
  #     define_method "#{name}_to_metro2" do
  #       val = instance_variable_get("@#{name}")
  #       Metro2.numeric_to_metro2(val, required_length, is_monetary)
  #     end
  #   end
  #
  #   def alphanumeric_const_field(name, required_length, val, permitted_chars = Metro2::ALPHANUMERIC)
  #     fields << name
  #
  #     # getter
  #     define_method name do
  #       val
  #     end
  #
  #     # to_metro2
  #
  #     define_method "#{name}_to_metro2" do
  #       Metro2.alphanumeric_to_metro2(val, required_length, permitted_chars, name)
  #     end
  #   end
  #
  #   def numeric_const_field(name, required_length, val, is_monetary = false)
  #     fields << name
  #
  #     # getter
  #     define_method name do
  #       val
  #     end
  #
  #     # to_metro2
  #     define_method "#{name}_to_metro2" do
  #       Metro2.numeric_to_metro2(val, required_length, is_monetary)
  #     end
  #   end
  #
  #   def monetary_field(name)
  #     numeric_field(name, 9, true)
  #   end
  #
  #   def date_field(name)
  #     fields << name
  #
  #     # getter
  #     define_method name do
  #       instance_variable_get("@#{name}")
  #     end
  #
  #     # setter (includes validations)
  #     define_method "#{name}=" do | val |
  #       instance_variable_set("@#{name}", val)
  #     end
  #
  #     # to_metro2
  #     define_method "#{name}_to_metro2" do
  #       # Right justified and zero-filled
  #       val = instance_variable_get("@#{name}")
  #       val = val&.strftime('%m%d%Y')
  #
  #       Metro2.numeric_to_metro2(val, 8, false)
  #     end
  #   end
  #
  #   def timestamp_field(name)
  #     fields << name
  #
  #     # getter
  #     define_method name do
  #       instance_variable_get("@#{name}")
  #     end
  #
  #     # setter (includes validations)
  #     define_method "#{name}=" do | val |
  #       instance_variable_set("@#{name}", val)
  #     end
  #
  #     # to_metro2
  #     define_method "#{name}_to_metro2" do
  #       # Right justified and zero-filled
  #       val = instance_variable_get("@#{name}")
  #       val = val&.strftime('%m%d%Y%H%M%S')
  #       Metro2.numeric_to_metro2(val, 14, false)
  #     end
  #   end
end
