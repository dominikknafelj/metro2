defmodule Metro2.Records.TailerSegment do
    @moduledoc """
  This module defines the initial struct for a tailer segment. This segment will updated based on the
  information of the other segments. 
  """
  alias Metro2.Fields.Alphanumeric
  alias Metro2.Fields.Numeric
  import Metro2.Fields, only: [get: 2, put: 3]
  import Metro2.Segment, only: [to_metro2: 1]

  defstruct [
    record_descriptor_word: %Numeric{ value: Metro2.Base.fixed_length, required_length: 4 },
    record_identifier: %Alphanumeric{ value: "TRAILER", required_length: 6 },
    total_base_records: %Numeric{ required_length: 9, value: 0 },
    reserved: %Alphanumeric{ required_length: 9, value: nil },
    total_status_code_df: %Numeric{ required_length: 9, value: 0 },
    total_j1_segments: %Numeric{ required_length: 9, value: 0 },
    total_j2_segments: %Numeric{ required_length: 9, value: 0 },
    block_count: %Numeric{ required_length: 9, value: 0 },
    total_status_code_da: %Numeric{ required_length: 9, value: 0 },
    total_status_code_05: %Numeric{ required_length: 9, value: 0 },
    total_status_code_11: %Numeric{ required_length: 9, value: 0 },
    total_status_code_13: %Numeric{ required_length: 9, value: 0 },
    total_status_code_61: %Numeric{ required_length: 9, value: 0 },
    total_status_code_62: %Numeric{ required_length: 9, value: 0 },
    total_status_code_63: %Numeric{ required_length: 9, value: 0 },
    total_status_code_64: %Numeric{ required_length: 9, value: 0 },
    total_status_code_65: %Numeric{ required_length: 9, value: 0 },
    total_status_code_71: %Numeric{ required_length: 9, value: 0 },
    total_status_code_78: %Numeric{ required_length: 9, value: 0 },
    total_status_code_80: %Numeric{ required_length: 9, value: 0 },
    total_status_code_82: %Numeric{ required_length: 9, value: 0 },
    total_status_code_83: %Numeric{ required_length: 9, value: 0 },
    total_status_code_84: %Numeric{ required_length: 9, value: 0 },
    total_status_code_88: %Numeric{ required_length: 9, value: 0 },
    total_status_code_89: %Numeric{ required_length: 9, value: 0 },
    total_status_code_93: %Numeric{ required_length: 9, value: 0 },
    total_status_code_94: %Numeric{ required_length: 9, value: 0 },
    total_status_code_95: %Numeric{ required_length: 9, value: 0 },
    total_status_code_96: %Numeric{ required_length: 9, value: 0 },
    total_status_code_97: %Numeric{ required_length: 9, value: 0 },
    ecoa_code_z: %Numeric{ required_length: 9, value: 0 },
    total_n1_segments: %Numeric{ required_length: 9, value: 0 },
    total_k1_segments: %Numeric{ required_length: 9, value: 0 },
    total_k2_segments: %Numeric{ required_length: 9, value: 0 },
    total_k3_segments: %Numeric{ required_length: 9, value: 0 },
    total_k4_segments: %Numeric{ required_length: 9, value: 0 },
    total_l1_segments: %Numeric{ required_length: 9, value: 0 },
    total_social_security_numbers: %Numeric{ required_length: 9, value: 0 },
    total_social_security_numbers_in_base: %Numeric{ required_length: 9, value: 0 },
    total_social_security_numbers_in_j1: %Numeric{ required_length: 9, value: 0 },
    total_social_security_numbers_in_j2: %Numeric{ required_length: 9, value: 0 },
    total_date_of_births: %Numeric{ required_length: 9, value: 0 },
    total_date_of_births_in_base: %Numeric{ required_length: 9, value: 0 },
    total_date_of_births_in_j1: %Numeric{ required_length: 9, value: 0 },
    total_date_of_births_in_j2: %Numeric{ required_length: 9, value: 0 },
    total_telephone_numbers: %Numeric{ required_length: 9, value: 0 },
    reserved_2: %Alphanumeric{ required_length: 19, value: nil },
  ]

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
  def to_metro2(segment), do: Metro2.Segment.to_metro2(segment)
end
