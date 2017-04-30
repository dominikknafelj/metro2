defmodule Metro2.Segment do
  alias Metro2.Fields

  def to_metro2(%{}= segment) do
    segment |> Map.values |> Enum.filter_map( &is_map/1, &Fields.to_metro2/1)
  end

  def to_metro2([]= segments) do
    segments |> Enum.filter_map( &is_map/1, &to_metro2/1)
  end
end