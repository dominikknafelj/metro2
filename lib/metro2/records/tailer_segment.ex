defmodule Metro2.Records.TailerSegment do
    @moduledoc """
  This module defines the initial struct for a tailer segment. This segment will updated based on the
  information of the other segments. 
  """
  alias Metro2.Fields.Alphanumeric
  alias Metro2.Fields.Numeric
  import Metro2.Fields, only: [get: 2, put: 3]
  alias Metro2.Segment

  defstruct [
    :record_descriptor_word,
    :record_identifier,
    :total_base_records,
    :reserved,
    :total_status_code_df,
    :total_j1_segments,
    :total_j2_segments,
    :block_count,
    :total_status_code_da,
    :total_status_code_05,
    :total_status_code_11,
    :total_status_code_13,
    :total_status_code_61,
    :total_status_code_62,
    :total_status_code_63,
    :total_status_code_64,
    :total_status_code_65,
    :total_status_code_71,
    :total_status_code_78,
    :total_status_code_80,
    :total_status_code_82,
    :total_status_code_83,
    :total_status_code_84,
    :total_status_code_88,
    :total_status_code_89,
    :total_status_code_93,
    :total_status_code_94,
    :total_status_code_95,
    :total_status_code_96,
    :total_status_code_97,
    :ecoa_code_z,
    :total_n1_segments,
    :total_k1_segments,
    :total_k2_segments,
    :total_k3_segments,
    :total_k4_segments,
    :total_l1_segments,
    :total_social_security_numbers,
    :total_social_security_numbers_in_base,
    :total_social_security_numbers_in_j1,
    :total_social_security_numbers_in_j2,
    :total_date_of_births,
    :total_date_of_births_in_base,
    :total_date_of_births_in_j1,
    :total_date_of_births_in_j2,
    :total_telephone_numbers,
    :reserved_2,
  ]

  @doc """
  Creates a new TailerSegment with properly initialized fields
  """
  def new do
    %__MODULE__{
      record_descriptor_word: Numeric.new(4, Metro2.Base.fixed_length()),
      record_identifier: Alphanumeric.new(6, "TRAILER"),
      total_base_records: Numeric.new(9, 0),
      reserved: Alphanumeric.new(9, nil),
      total_status_code_df: Numeric.new(9, 0),
      total_j1_segments: Numeric.new(9, 0),
      total_j2_segments: Numeric.new(9, 0),
      block_count: Numeric.new(9, 0),
      total_status_code_da: Numeric.new(9, 0),
      total_status_code_05: Numeric.new(9, 0),
      total_status_code_11: Numeric.new(9, 0),
      total_status_code_13: Numeric.new(9, 0),
      total_status_code_61: Numeric.new(9, 0),
      total_status_code_62: Numeric.new(9, 0),
      total_status_code_63: Numeric.new(9, 0),
      total_status_code_64: Numeric.new(9, 0),
      total_status_code_65: Numeric.new(9, 0),
      total_status_code_71: Numeric.new(9, 0),
      total_status_code_78: Numeric.new(9, 0),
      total_status_code_80: Numeric.new(9, 0),
      total_status_code_82: Numeric.new(9, 0),
      total_status_code_83: Numeric.new(9, 0),
      total_status_code_84: Numeric.new(9, 0),
      total_status_code_88: Numeric.new(9, 0),
      total_status_code_89: Numeric.new(9, 0),
      total_status_code_93: Numeric.new(9, 0),
      total_status_code_94: Numeric.new(9, 0),
      total_status_code_95: Numeric.new(9, 0),
      total_status_code_96: Numeric.new(9, 0),
      total_status_code_97: Numeric.new(9, 0),
      ecoa_code_z: Numeric.new(9, 0),
      total_n1_segments: Numeric.new(9, 0),
      total_k1_segments: Numeric.new(9, 0),
      total_k2_segments: Numeric.new(9, 0),
      total_k3_segments: Numeric.new(9, 0),
      total_k4_segments: Numeric.new(9, 0),
      total_l1_segments: Numeric.new(9, 0),
      total_social_security_numbers: Numeric.new(9, 0),
      total_social_security_numbers_in_base: Numeric.new(9, 0),
      total_social_security_numbers_in_j1: Numeric.new(9, 0),
      total_social_security_numbers_in_j2: Numeric.new(9, 0),
      total_date_of_births: Numeric.new(9, 0),
      total_date_of_births_in_base: Numeric.new(9, 0),
      total_date_of_births_in_j1: Numeric.new(9, 0),
      total_date_of_births_in_j2: Numeric.new(9, 0),
      total_telephone_numbers: Numeric.new(9, 0),
      reserved_2: Alphanumeric.new(19, nil),
    }
  end

  # this function increments field in the segment
  @doc false
  def increment_field(%Metro2.Records.TailerSegment{} = segment, field ) do
    case get(segment, field) do
      x when x == nil -> put(segment, field, 1)
      x when is_integer(x) -> put(segment, field, x+1)
      x -> raise ArgumentError, message: "Field '#{field}' has invalid value #{x}, it has to be an integer!"
    end
  end

  @doc false
  def to_metro2(segment), do: Segment.to_metro2(segment)
end
