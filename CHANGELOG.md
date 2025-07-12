# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2024-01-XX

### Changed
- **BREAKING**: Upgraded minimum Elixir version from `~> 1.4` to `~> 1.14`
- Updated `timex` dependency from `~> 3.0` to `~> 3.7`
- Updated `credo` dependency from `~> 0.7` to `~> 1.7`
- Updated `ex_doc` dependency from `~> 0.14` to `~> 0.31`
- Migrated from deprecated `Mix.Config` to `Config` module
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