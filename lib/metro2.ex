defmodule Metro2 do
  @moduledoc """
  Metro2 is a library for generating METRO 2® format files for credit bureau reporting.

  METRO 2® is a data reporting format for consumer credit account data furnishers.

  ## Usage

  Create a Metro2 file with header, base segments, and tailer:

      file = %Metro2.File{}
      |> Metro2.File.add_base_segment(base_segment)
      |> Metro2.File.serialize()

  ## Modules

  - `Metro2.File` - Main file structure and serialization
  - `Metro2.Fields` - Field type definitions and operations
  - `Metro2.Records.HeaderSegment` - Header segment definition
  - `Metro2.Records.BaseSegment` - Base segment definition  
  - `Metro2.Records.TailerSegment` - Tailer segment definition
  - `Metro2.Base` - Base constants and utility functions
  """

  alias Metro2.File

  @doc """
  Creates a new Metro2 file structure.
  """
  def new_file do
    %File{}
  end

  @doc """
  Adds a base segment to a Metro2 file.
  """
  def add_base_segment(file, base_segment) do
    File.add_base_segment(file, base_segment)
  end

  @doc """
  Serializes a Metro2 file to the METRO 2® format string.
  """
  def serialize(file) do
    File.serialize(file)
  end
end
