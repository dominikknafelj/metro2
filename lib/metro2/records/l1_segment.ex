defmodule Metro2.Records.L1Segment do
  @moduledoc """
  L1 segment: account number / identification number change.
  `change_indicator`: "1" (`:account_number`), "2" (`:identification_number`), "3" (`:both`).
  54 characters, appended to a base segment with `Metro2.Records.BaseSegment.add_segment/2`.
  """
  alias Metro2.Fields.Alphanumeric

  # Declaration order is the METRO 2 segment layout order; serialization relies on it.
  @fields [
    :segment_identifier,
    :change_indicator,
    :new_consumer_account_number,
    :new_identification_number,
    :reserved
  ]

  defstruct @fields

  @doc false
  def fields, do: @fields

  @doc false
  def segment_key, do: :l1

  @doc false
  def record_length, do: 54

  @doc """
  Creates a new L1Segment with properly initialized fields
  """
  def new do
    %__MODULE__{
      segment_identifier: Alphanumeric.new(2, "L1"),
      change_indicator: Alphanumeric.new_code(1, :change_indicator),
      new_consumer_account_number: Alphanumeric.new(30),
      new_identification_number: Alphanumeric.new(20),
      reserved: Alphanumeric.new(1)
    }
  end
end
