defmodule Metro2.Records.TailerSegment do
  @moduledoc """
  This module defines the initial struct for a tailer segment. This segment will updated based on the
  information of the other segments. 
  """
  alias Metro2.Fields.Alphanumeric
  alias Metro2.Fields.Numeric
  import Metro2.Fields, only: [get: 2, put: 3]
  alias Metro2.Records.BaseSegment
  alias Metro2.Segment

  # Declaration order is the METRO 2 record layout order; serialization relies on it.
  @fields [
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
    :reserved_2
  ]

  defstruct @fields

  @doc false
  def fields, do: @fields

  @doc false
  def record_length, do: Metro2.Base.fixed_length()

  @doc """
  Creates a new TailerSegment with properly initialized fields
  """
  def new do
    %__MODULE__{
      record_descriptor_word: Numeric.new(4, Metro2.Base.fixed_length()),
      record_identifier: Alphanumeric.new(7, "TRAILER"),
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
      reserved_2: Alphanumeric.new(19, nil)
    }
  end

  # this function increments field in the segment
  @doc false
  def increment_field(%Metro2.Records.TailerSegment{} = segment, field) do
    case get(segment, field) do
      x when x == nil ->
        put(segment, field, 1)

      x when is_integer(x) ->
        put(segment, field, x + 1)

      x ->
        raise ArgumentError,
          message: "Field '#{field}' has invalid value #{x}, it has to be an integer!"
    end
  end

  @status_fields Map.new(Metro2.Base.account_status(), fn {_, code} ->
                   {code, :"total_status_code_#{String.downcase(code)}"}
                 end)

  @appendage_fields %{
    j1: :total_j1_segments,
    j2: :total_j2_segments,
    k1: :total_k1_segments,
    k2: :total_k2_segments,
    k3: :total_k3_segments,
    k4: :total_k4_segments,
    l1: :total_l1_segments,
    n1: :total_n1_segments
  }

  @doc """
  Returns the tailer counter field for an account status code, or `nil` for unknown codes.
  """
  def status_field(code), do: Map.get(@status_fields, code)

  # adds the counts of one base segment (including its appended segments) to a counts map.
  # Only valid segments should be counted; see Metro2.File.validate/1.
  @doc false
  def count(counts, %BaseSegment{} = base) do
    associated = base.j1 ++ base.j2

    counts
    |> add(:total_base_records)
    |> add(status_field(Segment.value(base, :account_status)))
    |> add_present(base, :social_security_number, :total_social_security_numbers_in_base)
    |> add_present(base, :date_of_birth, :total_date_of_births_in_base)
    |> add(
      :total_social_security_numbers,
      count_present([base | associated], :social_security_number)
    )
    |> add(:total_date_of_births, count_present([base | associated], :date_of_birth))
    |> add(:total_telephone_numbers, count_present([base | associated], :telephone_number))
    |> add(:ecoa_code_z, Enum.count([base | associated], &(Segment.value(&1, :ecoa_code) == "Z")))
    |> add(:total_social_security_numbers_in_j1, count_present(base.j1, :social_security_number))
    |> add(:total_social_security_numbers_in_j2, count_present(base.j2, :social_security_number))
    |> add(:total_date_of_births_in_j1, count_present(base.j1, :date_of_birth))
    |> add(:total_date_of_births_in_j2, count_present(base.j2, :date_of_birth))
    |> add_appendages(base)
  end

  # builds a tailer segment from a counts map
  @doc false
  def from_counts(counts) do
    Enum.reduce(counts, new(), fn {field, count}, tailer -> put(tailer, field, count) end)
  end

  defp add_appendages(counts, base) do
    base
    |> BaseSegment.appendages()
    |> Enum.reduce(counts, fn segment, acc ->
      add(acc, Map.fetch!(@appendage_fields, segment.__struct__.segment_key()))
    end)
  end

  defp add_present(counts, segment, field, counter) do
    add(counts, counter, count_present([segment], field))
  end

  defp count_present(segments, field), do: Enum.count(segments, &Segment.present?(&1, field))

  defp add(counts, field, amount \\ 1)
  defp add(counts, nil, _amount), do: counts
  defp add(counts, field, amount), do: Map.update(counts, field, amount, &(&1 + amount))

  @doc false
  def to_metro2(segment), do: Segment.to_metro2(segment)
end
