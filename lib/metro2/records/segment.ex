defmodule Metro2.Segment do
  @moduledoc """
  This module defines the to_metro method for header-, base- and tailer-segment.
  """
  alias Metro2.Fields
  
  @doc false
  # this function returns a list of the metro2 converted fields of the segment
  def to_metro2(%{}= segment) do
    segment 
    |> Map.values 
    |> Enum.filter(&is_map/1)
    |> Enum.map(&Fields.to_metro2/1)
  end
end