defmodule Metro2.Records.K2Segment do
  @moduledoc """
  K2 segment: purchased from / sold to.
  `purchased_from_sold_to_indicator`: "1" purchased from, "2" sold to, "9" remove.
  34 characters, appended to a base segment with `Metro2.Records.BaseSegment.add_segment/2`.
  """
  alias Metro2.Fields.Alphanumeric

  # Declaration order is the METRO 2 segment layout order; serialization relies on it.
  @fields [
    :segment_identifier,
    :purchased_from_sold_to_indicator,
    :purchased_from_sold_to_name,
    :reserved
  ]

  defstruct @fields

  @doc false
  def fields, do: @fields

  @doc false
  def segment_key, do: :k2

  @doc false
  def record_length, do: 34

  @doc """
  Creates a new K2Segment with properly initialized fields
  """
  def new do
    %__MODULE__{
      segment_identifier: Alphanumeric.new(2, "K2"),
      purchased_from_sold_to_indicator: Alphanumeric.new_enum(1, ~w(1 2 9)),
      purchased_from_sold_to_name: Alphanumeric.new_with_dot_dash_slash(30),
      reserved: Alphanumeric.new(1)
    }
  end
end
