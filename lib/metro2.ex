defmodule Metro2 do
  @moduledoc """
  Metro2 is a library for generating and parsing METRO 2® format files for credit bureau
  reporting.

  METRO 2® is a data reporting format for consumer credit account data furnishers.

  ## Usage

  Create a Metro2 file with header, base segments, and tailer:

      Metro2.File.new()
      |> Metro2.File.add_base_segment(base_segment)
      |> Metro2.File.serialize()

  ## Modules

  - `Metro2.File` - Main file structure, validation, serialization and streaming
  - `Metro2.Parser` - Parses METRO 2® character format content
  - `Metro2.Fields` - Field type definitions and operations
  - `Metro2.Rules` - Cross-field consistency rules
  - `Metro2.Records.HeaderSegment` - Header segment definition
  - `Metro2.Records.BaseSegment` - Base segment definition
  - `Metro2.Records.TailerSegment` - Tailer segment definition
  - `Metro2.Records.J1Segment`, `J2Segment`, `K1Segment` ... `N1Segment` - Appended segments
  - `Metro2.Base` - Base constants, code tables and utility functions
  """

  alias Metro2.File

  @doc """
  Creates a new Metro2 file structure.
  """
  def new_file, do: File.new()

  @doc """
  Adds a base segment to a Metro2 file.
  """
  def add_base_segment(file, base_segment), do: File.add_base_segment(file, base_segment)

  @doc """
  Validates a Metro2 file. See `Metro2.File.validate/1`.
  """
  def validate(file), do: File.validate(file)

  @doc """
  Returns warnings for likely data problems. See `Metro2.File.warnings/1`.
  """
  def warnings(file), do: File.warnings(file)

  @doc """
  Serializes a Metro2 file to the METRO 2® format string.
  """
  def serialize(file), do: File.serialize(file)

  @doc """
  Parses METRO 2® content into a Metro2 file. See `Metro2.Parser.parse/1`.
  """
  def parse(content), do: Metro2.Parser.parse(content)
end
