defmodule Metro2.File do
  @moduledoc """
  This module defines the initial struct of the the metro2 file struct, further it contains the serialisation method,
  which ultimately returns a string containing the struct as valid metro2 file content.

  Records are written one per line: the header, the base segments in the order they were
  added, and a tailer computed from the base segments. For large files use `stream/2`,
  which never holds more than one base segment in memory.
  """
  alias Metro2.Records.BaseSegment
  alias Metro2.Records.HeaderSegment
  alias Metro2.Records.TailerSegment
  alias Metro2.Rules
  alias Metro2.Segment
  alias Metro2.ValidationError

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

  @doc """
  Add a base segment to the file. `base_segments` is kept newest-first internally;
  segments are serialized in the order they were added.
  """
  def add_base_segment(%Metro2.File{} = file, %BaseSegment{} = segment) do
    list = Map.get(file, :base_segments)
    Map.put(file, :base_segments, [segment | list])
  end

  @doc """
  Validates every field of the header and base segments (including appended segments) and
  the cross-field rules of `Metro2.Rules`.

  Returns `:ok` or `{:error, errors}` with all errors; see `Metro2.ValidationError` for
  their shape.
  """
  def validate(%Metro2.File{} = file) do
    header_errors = errors_for(:header, :header, file.header)

    base_errors =
      file.base_segments
      |> Enum.reverse()
      |> Enum.with_index(1)
      |> Enum.flat_map(fn {base, index} -> base_errors(base, index) end)

    case header_errors ++ base_errors do
      [] -> :ok
      errors -> {:error, errors}
    end
  end

  @doc """
  converts and serializes a Metro2.File struct into a Metro2 conform string.
  Raises `Metro2.ValidationError` listing every invalid field when the file is invalid.
  """
  def serialize(%Metro2.File{} = file) do
    case validate(file) do
      :ok -> file.header |> stream(Enum.reverse(file.base_segments)) |> Enum.join()
      {:error, errors} -> raise ValidationError, errors: errors
    end
  end

  @doc """
  Lazily serializes a header and an enumerable of base segments into a stream of strings
  (header, one per base segment, tailer). The tailer counts are accumulated while streaming.

  Each record is validated as it is emitted; an invalid record raises
  `Metro2.ValidationError` while the stream is consumed.

      Metro2.File.stream(header, accounts_stream)
      |> Stream.into(Elixir.File.stream!("out.metro2"))
      |> Stream.run()
  """
  def stream(%HeaderSegment{} = header, base_segments) do
    header = with_default_dates(header)

    case errors_for(:header, :header, header) do
      [] -> :ok
      errors -> raise ValidationError, errors: errors
    end

    base_records =
      base_segments
      |> Stream.concat([:tailer])
      |> Stream.transform({1, %{}}, fn
        :tailer, {index, counts} ->
          {["\n" <> Segment.to_metro2(TailerSegment.from_counts(counts))], {index, counts}}

        %BaseSegment{} = base, {index, counts} ->
          case base_errors(base, index) do
            [] ->
              {["\n" <> Segment.to_metro2(base)], {index + 1, TailerSegment.count(counts, base)}}

            errors ->
              raise ValidationError, errors: errors
          end
      end)

    Stream.concat([Segment.to_metro2(header)], base_records)
  end

  defp with_default_dates(header) do
    today = Date.utc_today()

    Enum.reduce([:activity_date, :created_date], header, fn field, acc ->
      if Metro2.Fields.get(acc, field) == nil, do: Metro2.Fields.put(acc, field, today), else: acc
    end)
  end

  defp base_errors(base, index) do
    record = {:base, index}

    rule_errors =
      for {field, message} <- Rules.base_errors(base),
          do: %{record: record, segment: :base, field: field, message: message}

    appendage_errors =
      base
      |> BaseSegment.appendages()
      |> Enum.flat_map(&errors_for(record, &1.__struct__.segment_key(), &1))

    errors_for(record, :base, base) ++ rule_errors ++ appendage_errors
  end

  defp errors_for(record, segment_name, segment) do
    for {field, message} <- Segment.field_errors(segment),
        do: %{record: record, segment: segment_name, field: field, message: message}
  end
end
