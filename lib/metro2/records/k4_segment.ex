defmodule Metro2.Records.K4Segment do
  @moduledoc """
  K4 segment: specialized payment information.
  `specialized_payment_indicator`: "01" balloon payment, "02" deferred payment.
  30 characters, appended to a base segment with `Metro2.Records.BaseSegment.add_segment/2`.
  """
  alias Metro2.Fields.Alphanumeric
  alias Metro2.Fields.Date
  alias Metro2.Fields.Monetary

  # Declaration order is the METRO 2 segment layout order; serialization relies on it.
  @fields [
    :segment_identifier,
    :specialized_payment_indicator,
    :deferred_payment_start_date,
    :balloon_payment_due_date,
    :balloon_payment_amount,
    :reserved
  ]

  defstruct @fields

  @doc false
  def fields, do: @fields

  @doc false
  def segment_key, do: :k4

  @doc false
  def record_length, do: 30

  @doc """
  Creates a new K4Segment with properly initialized fields
  """
  def new do
    %__MODULE__{
      segment_identifier: Alphanumeric.new(2, "K4"),
      specialized_payment_indicator: Alphanumeric.new_code(2, :specialized_payment_indicator),
      deferred_payment_start_date: Date.new(),
      balloon_payment_due_date: Date.new(),
      balloon_payment_amount: Monetary.new(),
      reserved: Alphanumeric.new(1)
    }
  end
end
