# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

An Elixir library (OTP app `:metro_2`, Hex package name `:metro2`) that generates and parses METRO 2® credit-reporting files in the 426-character format: header segment, base segments (one per reportable account, optionally with appended J1/J2/K1–K4/L1/N1 segments), and an auto-computed tailer segment. It is a port of the Ruby gem `teamupstart/metro_2`. The 366-byte packed format is not implemented.

## Commands

```sh
mix deps.get
mix compile --warnings-as-errors   # CI fails on warnings
mix test                           # all tests
mix test test/metro2_base_test.exs          # one file
mix test test/metro2_base_test.exs:45       # one test by line
mix format --check-formatted       # line_length: 100
mix credo --strict
mix deps.unlock --check-unused
mix run demo.exs                   # smoke test; writes demo_output.metro2 (gitignored)
```

CI (`.github/workflows/ci.yml`) runs the test job on Elixir 1.14–1.17 / OTP 25–27 and a separate quality job (format, credo --strict, unused deps). Run all of the above before considering a change done.

User-facing docs live in `guides/usage.md` and `guides/segments.md` (ex_doc extras, see `docs/0` in `mix.exs`). Keep their code examples runnable when changing the API.

## Architecture

Data flows **segment struct of field structs → `Fields.format/1` per field → `Segment.to_metro2/1` per record → `File.stream/2` / `File.serialize/1`**. `Metro2.Parser` runs the same layout in reverse via each field type's `width/1` and `parse/2`.

- **Field structs** (`lib/metro2/fields.ex`): `Alphanumeric`, `Numeric`, `Monetary`, `Date`, `TimeStamp`. Each holds `:value` plus formatting metadata and implements `format/1` (`{:ok, string} | {:error, message}`), `width/1`, `parse/2`. `Fields.to_metro2/1` is the raising wrapper.
- **Alphanumeric normalization** happens in the field layer, not in `Base`: NFD + strip combining marks, strip per-constructor `strip_chars`, collapse spaces, upcase, then code lookup/validation. `Base.format_alphanumeric/3` / `format_numeric/3` are raw pad/truncate/validate primitives (their raising wrappers `alphanumeric_to_metro2/3`, `numeric_to_metro2/3` are tested directly and must not upcase).
- **Constructors pick the rules**: `Alphanumeric.new/3` (alnum + space, `strip:` opt), `new_with_dash/2` (names, strips `'`), `new_with_dot_dash_slash/2` (addresses, strips `' , #`), `new_code/3` (backed by a `Base` code table; closed lists come from `Base.valid_codes/1`, `nil` = open), `new_enum/3`; `Numeric.new_identifier/2` strips separators for SSN/phone.
- **Segments** (`lib/metro2/records/`): structs whose layout keys hold field structs. Always construct with `XSegment.new()` — a bare `%BaseSegment{}` has `nil` fields. `BaseSegment` also has non-field keys `j1`/`j2` (lists) and `k1`..`n1` (single) for appended segments, which `add_segment/2` fills and `appendages/1` returns in write order. Appended segment modules define `segment_key/0` and `record_length/0`.
- **Validation** (`File.validate/1`): per-field format errors (`Segment.field_errors/1`) + `Metro2.Rules.base_errors/1` cross-field rules + appended-segment field errors, as `%{record, segment, field, message}` maps. `Fields.put/3` deliberately does not validate; `Fields.cast/3` does.
- **Tailer is derived, not set**: `File.stream/2` accumulates a counts map via `TailerSegment.count/2` while emitting base records and builds the tailer with `from_counts/1`. Counting reads *formatted* values (`Segment.value/2`, `Segment.present?/2`), so normalization (e.g. `5` → `"05"`, `z` → `Z`) applies. Status counters come from the compile-time `@status_fields` map built from `Base.account_status/0`.
- `File.add_base_segment/2` prepends; `serialize/1`, `validate/1` (record indexes) and `stream/2` all work in insertion order via `Enum.reverse/1`.

### Record layout

Each segment module declares its fields in an ordered `@fields` list (used for both `defstruct` and `fields/0`). The list order *is* the METRO 2 position layout, so adding or reordering a field means placing it at its spec position. Header, base (fixed part) and tailer are exactly 426 characters (`Base.fixed_length/0`); a base record's descriptor word is set at serialization to 426 plus its appended segments' lengths. `test/metro_2_test.exs` and `test/metro2_compliance_test.exs` assert record lengths, field offsets, tailer counts, and a parser round trip.
