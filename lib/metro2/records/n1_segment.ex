defmodule Metro2.Records.N1Segment do
  @moduledoc """
  N1 segment: employment information.
  146 characters, appended to a base segment with `Metro2.Records.BaseSegment.add_segment/2`.
  """
  alias Metro2.Fields.Alphanumeric

  # Declaration order is the METRO 2 segment layout order; serialization relies on it.
  @fields [
    :segment_identifier,
    :employer_name,
    :first_line_of_employer_address,
    :second_line_of_employer_address,
    :employer_city,
    :employer_state,
    :employer_postal_code,
    :occupation,
    :reserved
  ]

  defstruct @fields

  @doc false
  def fields, do: @fields

  @doc false
  def segment_key, do: :n1

  @doc false
  def record_length, do: 146

  @doc """
  Creates a new N1Segment with properly initialized fields
  """
  def new do
    %__MODULE__{
      segment_identifier: Alphanumeric.new(2, "N1"),
      employer_name: Alphanumeric.new_with_dot_dash_slash(30),
      first_line_of_employer_address: Alphanumeric.new_with_dot_dash_slash(32),
      second_line_of_employer_address: Alphanumeric.new_with_dot_dash_slash(32),
      employer_city: Alphanumeric.new_with_dot_dash_slash(20),
      employer_state: Alphanumeric.new(2),
      employer_postal_code: Alphanumeric.new(9, nil, strip: ~r/-/),
      occupation: Alphanumeric.new_with_dot_dash_slash(18),
      reserved: Alphanumeric.new(1)
    }
  end
end
