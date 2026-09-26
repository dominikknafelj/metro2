defmodule Metro2.Records.K3Segment do
  @moduledoc """
  K3 segment: mortgage information.
  40 characters, appended to a base segment with `Metro2.Records.BaseSegment.add_segment/2`.
  """
  alias Metro2.Fields.Alphanumeric

  # Declaration order is the METRO 2 segment layout order; serialization relies on it.
  @fields [
    :segment_identifier,
    :agency_identifier,
    :account_number,
    :mortgage_identification_number
  ]

  defstruct @fields

  @doc false
  def fields, do: @fields

  @doc false
  def segment_key, do: :k3

  @doc false
  def record_length, do: 40

  @doc """
  Creates a new K3Segment with properly initialized fields
  """
  def new do
    %__MODULE__{
      segment_identifier: Alphanumeric.new(2, "K3"),
      agency_identifier: Alphanumeric.new_code(2, :agency_identifier),
      account_number: Alphanumeric.new(18),
      mortgage_identification_number: Alphanumeric.new(18)
    }
  end
end
