defmodule Metro2.Records.J1Segment do
  @moduledoc """
  J1 segment: associated consumer with the same address as the base segment.
  100 characters, appended to a base segment with `Metro2.Records.BaseSegment.add_segment/2`.
  """
  alias Metro2.Fields.Alphanumeric
  alias Metro2.Fields.Date
  alias Metro2.Fields.Numeric

  # Declaration order is the METRO 2 segment layout order; serialization relies on it.
  @fields [
    :segment_identifier,
    :reserved,
    :surname,
    :first_name,
    :middle_name,
    :generation_code,
    :social_security_number,
    :date_of_birth,
    :telephone_number,
    :ecoa_code,
    :consumer_information_indicator,
    :reserved_2
  ]

  defstruct @fields

  @doc false
  def fields, do: @fields

  @doc false
  def segment_key, do: :j1

  @doc false
  def record_length, do: 100

  @doc """
  Creates a new J1Segment with properly initialized fields
  """
  def new do
    %__MODULE__{
      segment_identifier: Alphanumeric.new(2, "J1"),
      reserved: Alphanumeric.new(1),
      surname: Alphanumeric.new_with_dash(25),
      first_name: Alphanumeric.new_with_dash(20),
      middle_name: Alphanumeric.new_with_dash(20),
      generation_code: Alphanumeric.new_code(1, :generation_code),
      social_security_number: Numeric.new_identifier(9),
      date_of_birth: Date.new(),
      telephone_number: Numeric.new_identifier(10),
      ecoa_code: Alphanumeric.new_code(1, :ecoa_code),
      consumer_information_indicator: Alphanumeric.new_code(2, :consumer_information_indicator),
      reserved_2: Alphanumeric.new(1)
    }
  end
end
