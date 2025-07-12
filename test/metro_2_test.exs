defmodule Metro2Test do
  use ExUnit.Case
  doctest Metro2

  alias Metro2.{Fields, File, Records.BaseSegment}

  test "creates a valid metro2 file structure" do
    file = File.new()

    assert %File{
             header: %Metro2.Records.HeaderSegment{},
             base_segments: [],
             tailer: %Metro2.Records.TailerSegment{}
           } = file
  end

  test "adds base segment to file" do
    file = File.new()
    base_segment = BaseSegment.new()

    updated_file = File.add_base_segment(file, base_segment)

    assert length(updated_file.base_segments) == 1
    assert hd(updated_file.base_segments) == base_segment
  end

  test "serializes file to metro2 format" do
    file = File.new()

    serialized = File.serialize(file)

    assert is_binary(serialized)
    assert String.length(serialized) > 0
  end

  test "field operations work correctly" do
    base_segment = BaseSegment.new()

    # Test setting a field
    updated_segment = Fields.put(base_segment, :first_name, "John")

    # Test getting a field
    assert Fields.get(updated_segment, :first_name) == "John"
  end
end
