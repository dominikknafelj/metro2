defmodule Metro2.Records.HeaderSegment do
  @moduledoc """
    This module defines the initial struct for a header segment.
  """

  alias Metro2.Fields.Alphanumeric
  alias Metro2.Fields.Numeric
  alias Metro2.Fields.Date

  defstruct [
    :record_descriptor_word,
    :record_identifier,
    :cycle_number,
    :innovis_program_identifier,
    :equifax_program_identifier,
    :experian_program_identifier,
    :transunion_program_identifier,
    :activity_date,
    :created_date,
    :program_date,
    :program_revisition_date,
    :reporter_name,
    :reporter_address,
    :reporter_telephone_number,
    :software_vendor_name,
    :software_version_number,
    :reserved
   ]

  @doc """
  Creates a new HeaderSegment with properly initialized fields
  """
  def new do
    %__MODULE__{
      record_descriptor_word: Numeric.new(4, Metro2.Base.fixed_length()),
      record_identifier: Alphanumeric.new(6, "HEADER"),
      cycle_number: Alphanumeric.new(2),
      innovis_program_identifier: Alphanumeric.new(10),
      equifax_program_identifier: Alphanumeric.new(10),
      experian_program_identifier: Alphanumeric.new(5),
      transunion_program_identifier: Alphanumeric.new(10),
      activity_date: Date.new(),
      created_date: Date.new(),
      program_date: Date.new(),
      program_revisition_date: Date.new(),
      reporter_name: Alphanumeric.new(40),
      reporter_address: Alphanumeric.new_with_dot_dash_slash(96),
      reporter_telephone_number: Numeric.new(10),
      software_vendor_name: Alphanumeric.new(40, "Metro2Elix"),
      software_version_number: Alphanumeric.new(5, Metro2.Base.version_string()),
      reserved: Alphanumeric.new(156, nil)
    }
  end
  
  def to_metro2(segment), do: Metro2.Segment.to_metro2(segment)
end
