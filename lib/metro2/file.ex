defmodule Metro2.File do
  @moduledoc """
  This module defines the initial struct of the the metro2 file struct, further it contains the serialisation method,
  wich ultimately returns a string containing the struct as valid metro2 file content.
  """
  alias Metro2.Records.BaseSegment
  alias Metro2.Records.HeaderSegment
  alias Metro2.Records.TailerSegment
  alias Metro2.Segment

  import Metro2.Fields, only: [get: 2]

  defstruct [
    :header,
    :base_segments,
    :tailer
  ]

  @doc """
  Creates a new Metro2 File with properly initialized segments
  """
  def new do
    %__MODULE__{
      header: HeaderSegment.new(),
      base_segments: [],
      tailer: TailerSegment.new()
    }
  end

  # struct which map the fields from the base segments to the corresponding fields in the tailer segments
  @field_mapping %{
    ecoa_code: :ecoa_code_z,
    social_security_number: :total_social_security_numbers,
    date_of_birth: :total_date_of_births,
    telephone_number: :total_telephone_numbers
  }

  @doc """
  Add a base segement to the base segment list in the file struct.
  """
  def add_base_segment(%Metro2.File{} = file, %BaseSegment{} = segment) do
    list = Map.get(file, :base_segments)
    Map.put(file, :base_segments, [segment | list])
  end

  @doc """
  converts and serializes a Metro2.File struct into a Metro2 conform string
  """
  def serialize(%Metro2.File{} = file) do
    tailer_segment = TailerSegment.new() |> count_base_segment(file.base_segments)

    file
    |> Map.put(:tailer, tailer_segment)
    |> to_metro2
    |> List.flatten()
    |> Enum.join("\n")
  end

  @doc false
  # terminal definition for the base segment counter
  defp count_base_segment(%Metro2.Records.TailerSegment{} = tailer_segment, []), do: tailer_segment

  @doc false
  # recursive counter to update the tailer segment for each base segment.
  defp count_base_segment(%Metro2.Records.TailerSegment{} = tailer_segment, [head | tail]) do
    tailer_segment
    |> increment_status_code(head)
    |> conditional_increment(head, :social_security_number)
    |> conditional_increment(head, :date_of_birth)
    |> conditional_increment(head, :telephone_number)
    |> conditional_increment(head, :ecoa_code)
    |> increment_total_base_records
    |> count_base_segment(tail)
  end

  @doc false
  # counts up the total_base_records field in the tailer
  defp increment_total_base_records(%TailerSegment{} = tailer) do
    tailer |> TailerSegment.increment_field(:total_base_records)
  end

  @doc false
  # determines the status code of the base segment and counts the corresponding field in the tailer segment up.
  defp increment_status_code(%TailerSegment{} = tailer, %{} = segment) do
    account_status = get(segment, :account_status) |> account_status_to_s()
    tailer_field = ("total_status_code_" <> account_status) |> String.downcase() |> String.to_atom()
    tailer |> TailerSegment.increment_field(tailer_field)
  end

  @doc false
  # casts possible integer values to string.
  # default to current status when nil
  defp account_status_to_s(nil), do: "11"
  defp account_status_to_s(status) when is_integer(status), do: Integer.to_string(status)
  defp account_status_to_s(status) when is_binary(status), do: status

  @doc false
  # counts up the ecoa_code_z field in the tailer segment if the base segment's is z.
  defp conditional_increment(%TailerSegment{} = tailer, %{} = segment, :ecoa_code = field) do
    case get(segment, field) do
      x when x == "z" -> TailerSegment.increment_field(tailer, :ecoa_code_z)
      _ -> tailer
    end
  end

  @doc false
  # counts up the field in the tailer segment, if the corresponding value in the base segment is not nil
  defp conditional_increment(%TailerSegment{} = tailer, %{} = segment, field) do
    case get(segment, field) do
      nil -> tailer
      _ -> TailerSegment.increment_field(tailer, Map.get(@field_mapping, field))
    end
  end

  @doc false
  # generates a list with every segment in the metro2 file structure
  defp to_metro2(%Metro2.File{} = file) do
    elements =
      file.base_segments
      |> Enum.filter(&is_map/1)
      |> Enum.map(&Segment.to_metro2/1)

    [Segment.to_metro2(file.header) | elements] ++ [Segment.to_metro2(file.tailer)]
  end
end
