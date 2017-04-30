defmodule Metro2.File do
  alias Metro2.Records.HeaderSegment
  alias Metro2.Records.BaseSegment
  alias Metro2.Records.TailerSegment
  alias Metro2.Segment

  import Metro2.Fields, only: [get: 2]



  defstruct [
    header: %HeaderSegment{},
    base_segments: [],
    tailer: %TailerSegment{}
  ]

  @field_mapping %{
    ecoa_code: :ecoa_code_z,
    social_security_number: :total_social_security_numbers,
    date_of_birth: :total_date_of_births,
    telephone_number: :total_telephone_numbers
  }

  def add_base_segment( %Metro2.File{} = file, %BaseSegment{} = segment) do
    list = Map.get(file, :base_segments)
    Map.put(file, :base_segments, [segment | list])
  end

  def serialize( %Metro2.File{} = file ) do
     tailer_segment = %TailerSegment{} |> count_base_segment(file.base_segments)
     file 
     |> Map.put(:tailer, tailer_segment) 
     |> to_metro2
     |> List.flatten
     |> Enum.join("\n")
  end

  def count_base_segment(%Metro2.Records.TailerSegment{} = tailer_segment, []), do: tailer_segment

  def count_base_segment(%Metro2.Records.TailerSegment{} = tailer_segment, [head | tail]) do
    tailer_segment
    |> increment_status_code(head)
    |> conditional_increment( head, :social_security_number)
    |> conditional_increment( head, :date_of_birth)
    |> conditional_increment( head, :telephone_number)
    |> conditional_increment( head, :ecoa_code)
    |> count_base_segment(tail)
  end

  defp increment_status_code(%TailerSegment{} = tailer, %{} = segment) do
    account_status = get(segment, :account_status) |> account_status_to_s()
    tailer_field = "total_status_code_" <> account_status |> String.downcase |> String.to_atom
    tailer |> TailerSegment.increment_field(tailer_field)
  end

  defp account_status_to_s(status) when is_integer(status), do: Integer.to_string(status)
  defp account_status_to_s(status) when is_binary(status), do: status

  defp conditional_increment(%TailerSegment{} = tailer, %{} = segment, :ecoa_code = field) do
    case get(segment, field) do
      x when x == "z" -> TailerSegment.increment_field(tailer, :ecoa_code_z)
      _ -> tailer
    end
  end

  defp conditional_increment(%TailerSegment{} = tailer, %{} = segment, field) do
    case get(segment, field) do
      nil -> tailer
      _   -> TailerSegment.increment_field(tailer, Map.get(@field_mapping, field))
    end
  end

  defp to_metro2(%{} = file) do
    elements = Enum.filter_map( file.base_segments, &is_map/1, &Segment.to_metro2/1) ++ [Segment.to_metro2(file.tailer)]
    [Segment.to_metro2(file.header) | elements ]
  end
end
