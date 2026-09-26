defmodule Metro2.Records.K1Segment do
  @moduledoc """
  K1 segment: original creditor name.
  34 characters, appended to a base segment with `Metro2.Records.BaseSegment.add_segment/2`.
  """
  alias Metro2.Fields.Alphanumeric

  # Declaration order is the METRO 2 segment layout order; serialization relies on it.
  @fields [
    :segment_identifier,
    :original_creditor_name,
    :creditor_classification
  ]

  defstruct @fields

  @doc false
  def fields, do: @fields

  @doc false
  def segment_key, do: :k1

  @doc false
  def record_length, do: 34

  @doc """
  Creates a new K1Segment with properly initialized fields
  """
  def new do
    %__MODULE__{
      segment_identifier: Alphanumeric.new(2, "K1"),
      original_creditor_name: Alphanumeric.new_with_dot_dash_slash(30),
      creditor_classification: Alphanumeric.new_code(2, :creditor_classification)
    }
  end
end
