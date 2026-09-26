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

  describe "serialize/1 record layout" do
    setup do
      base_segment =
        BaseSegment.new()
        |> Fields.put(:account_status, "11")
        |> Fields.put(:surname, "Smith-Jones")
        |> Fields.put(:state, "NY")
        |> Fields.put(:residence_code, "R")

      lines =
        File.new() |> File.add_base_segment(base_segment) |> File.serialize() |> String.split("\n")

      %{lines: lines}
    end

    test "emits one line per segment: header, base segments, tailer", %{lines: lines} do
      assert length(lines) == 3
    end

    test "every record is fixed length and starts with the record descriptor word",
         %{lines: lines} do
      for line <- lines do
        assert String.length(line) == 426
        assert String.starts_with?(line, "0426")
      end
    end

    test "record identifiers are at their fixed positions", %{lines: [header, _base, tailer]} do
      assert String.slice(header, 4, 6) == "HEADER"
      assert String.slice(tailer, 4, 7) == "TRAILER"
    end

    test "base segment fields are emitted in METRO 2 position order", %{lines: [_, base, _]} do
      # 0-based offsets of the 426-character base segment layout
      assert String.slice(base, 123, 2) == "11"
      assert String.slice(base, 231, 25) == String.pad_trailing("SMITH-JONES", 25)
      assert String.slice(base, 413, 2) == "NY"
      assert String.slice(base, 425, 1) == "R"
    end

    test "tailer counts are emitted in METRO 2 position order", %{lines: [_, _, tailer]} do
      # total base records, then total status code 11 (after 11 preceding 9-digit counters)
      assert String.slice(tailer, 11, 9) == "000000001"
      assert String.slice(tailer, 83, 9) == "000000001"
    end
  end

  test "field operations work correctly" do
    base_segment = BaseSegment.new()

    # Test setting a field
    updated_segment = Fields.put(base_segment, :first_name, "John")

    # Test getting a field
    assert Fields.get(updated_segment, :first_name) == "John"
  end
end
