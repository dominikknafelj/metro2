# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-09-26

### Fixed
- **Records are now spec-compliant**: fields are written in METRO 2 position order (previously map order) and each record is one 426-character line (previously one line per field)
- Tailer record identifier is `TRAILER` (was truncated to `TRAILE`, making the tailer 425 characters)
- Negative monetary amounts are reported as zero instead of producing `000000-50`
- Newlines and tabs are rejected in alphanumeric fields (`\s` allowed them, which split records)
- ECOA code `Z` is counted in the tailer (only lowercase `z` was counted)
- `terms_frequency` `:semimonthly` is `E` (both semimonthly and semiannually were `S`)
- Tailer `*_in_base`, `*_in_j1`, `*_in_j2` SSN/date of birth counters are populated
- Base segments are serialized in insertion order (were reversed)
- Integer account statuses are zero padded (`5` → `05`) instead of crashing the tailer; tailer fields are no longer created with `String.to_atom`

### Added
- J1, J2, K1, K2, K3, K4, L1 and N1 appended segments (`BaseSegment.add_segment/2`)
- `Metro2.File.validate/1` collecting every invalid field and cross-field rule violation; `serialize/1` raises `Metro2.ValidationError` listing all of them
- `Metro2.Rules` cross-field consistency rules
- `Metro2.Fields.cast/3` to validate while setting a value
- `Metro2.File.stream/2` for lazy serialization of large files
- `Metro2.Parser` to parse 426-character METRO 2 content
- Closed code lists are enforced; code fields accept humanized atoms (`:current`)
- Complete ECOA, payment rating and compliance condition code lists
- Text normalization: upper casing, accent transliteration, removal of apostrophes (names) and commas/`#` (addresses), separators in SSNs/telephone numbers, dashes in postal codes
- Dates accept ISO 8601 strings, `DateTime` and `NaiveDateTime`
- Header `activity_date` and `created_date` default to today

### Changed
- **BREAKING**: `serialize/1` raises `Metro2.ValidationError` instead of `ArgumentError` and applies the cross-field rules
- **BREAKING**: header field `program_revisition_date` renamed to `program_revision_date`
- **BREAKING**: alphanumeric output is upper cased
- Removed the `timex` dependency (uses `Calendar.strftime/2`)
- README installation uses the Hex package name (`hex: :metro2`)

## [0.2.0] - 2025-07-12

### Changed
- **BREAKING**: Upgraded minimum Elixir version from `~> 1.4` to `~> 1.14`
- Updated `timex` dependency from `~> 3.0` to `~> 3.7`
- Updated `credo` dependency from `~> 0.7` to `~> 1.7`
- Updated `ex_doc` dependency from `~> 0.14` to `~> 0.31`
- Migrated from the deprecated Mix.Config module to `Config`
- Removed deprecated `build_embedded` and `preferred_cli_env` from mix.exs
- Removed deprecated `:applications` from application config
- Modernized mix.exs formatting and structure

### Added
- Comprehensive ExUnit test suite replacing ESpec
- Documentation configuration for better docs generation
- New test file `test/metro2_base_test.exs` with comprehensive Base module tests
- CHANGELOG.md file

### Removed
- **BREAKING**: Removed ESpec dependency and all ESpec test files
- Removed `spec/` directory and all its contents
- Removed `preferred_cli_env` configuration

### Fixed
- Fixed typo: `decimal_seperator` → `decimal_separator` in Metro2.Base
- Fixed typo: "sring" → "string" in Metro2.File documentation
- Improved code formatting and consistency

### Security
- Updated all dependencies to their latest secure versions
- Removed deprecated configurations that could cause issues

## [0.1.1] - Previous Version
- Initial implementation with METRO2 format support
- Basic header, base, and tailer segment support
- Field type abstractions (Alphanumeric, Numeric, Monetary, Date, TimeStamp)
- File serialization to METRO2 format 