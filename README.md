# Metro2
This library follows the METRO 2 ® data reporting format, which is a data reporting format for consumer credit account data furnishers.

It generates and parses the 426-character format, with structs for
 * header segments
 * base segments, with appended J1, J2, K1, K2, K3, K4, L1 and N1 segments
 * tailer segments (computed automatically)

 A port from the [Ruby implementation](https://github.com/teamupstart/metro_2)

## Installation

```elixir
def deps do
  [{:metro_2, "~> 0.3.0", hex: :metro2}]
end
```

## Documentation

- [Usage guide](guides/usage.md): building, validating, writing and reading files, with common account scenarios (current, past due, closed, charged off, joint accounts, account number changes)
- [Segments guide](guides/segments.md): what each segment (header, base, J1, J2, K1–K4, L1, N1, tailer) is for and what its fields mean

## Demo

Try the interactive demo to see the library in action with realistic credit reporting data:

```bash
mix run demo.exs
```

The demo showcases:
- ✅ **Character Validation**: Proper validation for names (with dashes), addresses (with dots/slashes), and regular fields
- ✅ **Realistic Data**: 3 consumer accounts with different scenarios (current, past due, closed)
- ✅ **METRO 2® Format**: Generates compliant format with header, base segments, and tailer
- ✅ **Error Handling**: Demonstrates rejection of invalid characters

**Output**: Creates `demo_output.metro2` with 5 fixed-length (426-character) METRO 2® records: header, 3 base segments, and tailer.

For detailed demo documentation, see [README_DEMO.md](https://github.com/dominikknafelj/metro2/blob/master/README_DEMO.md).

## Usage
Every segment struct contains field structs, which contain information about the individual field length, type and allowed characters, which are important for the serialization process. 

To access a field value in a segment struct:
```elixir
# Create a new base segment with proper field initialization
base_segment = Metro2.Records.BaseSegment.new()

# Set field values
base_segment = Metro2.Fields.put(base_segment, :first_name, "John-Smith")  # Dashes allowed in names
base_segment = Metro2.Fields.put(base_segment, :address_1, "123 Main St./Apt 2")  # Dots/slashes allowed in addresses

# Get field values
first_name = Metro2.Fields.get(base_segment, :first_name)
```
### METRO 2® File Structure
The Metro2 File Structure is the root structure and it has the following initial structure:
```elixir
defstruct [
    header: %HeaderSegment{},
    base_segments: [],
    tailer: %TailerSegment{}
  ]
```

Create and serialize a Metro2 file:

```elixir
# Create a new file with properly initialized segments
my_file = Metro2.File.new()

# Update header segment
my_file = %{my_file | header: Metro2.Fields.put(my_file.header, :reporter_name, "My Credit Union")}

# Add base segments
base_segment = Metro2.Records.BaseSegment.new()
|> Metro2.Fields.put(:surname, "Smith-Johnson")
|> Metro2.Fields.put(:first_name, "John")

my_file = Metro2.File.add_base_segment(my_file, base_segment)

# Serialize to METRO 2® format
metro2_content = Metro2.File.serialize(my_file)
```
### Header Segment
The header segment contains information about the data furnisher.
You should simply transform the header segment structure in the file structure.

### Base Segment
The base segment is stored in a list in the Metro2.File structure. Each base segment represents one reportable loan.
```elixir
# Create a base segment with proper character validation
base_segment = Metro2.Records.BaseSegment.new()
|> Metro2.Fields.put(:surname, "Smith-Johnson")        # Dashes allowed in names
|> Metro2.Fields.put(:first_name, "John")
|> Metro2.Fields.put(:address_1, "123 Main St./Apt 2") # Dots/slashes allowed in addresses  
|> Metro2.Fields.put(:account_status, "11")            # Current account
|> Metro2.Fields.put(:current_balance, 1500)

# Add to file
file = Metro2.File.new()
|> Metro2.File.add_base_segment(base_segment)
```

### Tailer Segment
The tailer segment contains counters for metrics like the SSN and the account statuses.
It will be completely auto-generated based on the base segments.

### Code Fields
Fields with METRO 2 code lists (`account_status`, `portfolio_type`, `ecoa_code`, `terms_frequency`, `payment_rating`, ...) accept either the code or the humanized atom from `Metro2.Base`:

```elixir
base_segment
|> Metro2.Fields.put(:account_status, :current)   # "11"
|> Metro2.Fields.put(:portfolio_type, "R")
```

Integers are zero padded (`5` → `"05"`), and codes outside a closed code list are rejected.

### Appended Segments
```elixir
alias Metro2.Records.{BaseSegment, J1Segment}

j1 = J1Segment.new() |> Metro2.Fields.put(:surname, "Doe") |> Metro2.Fields.put(:ecoa_code, "2")
base_segment = BaseSegment.add_segment(base_segment, j1)
```

J1 and J2 segments accumulate; K1–K4, L1 and N1 occur at most once. The record descriptor word reflects the total record length, and the tailer counts the appended segments.

### Validation
`Metro2.File.validate/1` returns `:ok` or `{:error, errors}` with **every** invalid field (character rules, code lists, lengths) and cross-field rule violation (see `Metro2.Rules`), each tagged with its record. `Metro2.File.serialize/1` raises `Metro2.ValidationError` listing them. To validate while setting a single value, use `Metro2.Fields.cast/3`.

### Streaming Large Files
`Metro2.File.stream/2` serializes lazily, so millions of accounts never need to be in memory at once:

```elixir
Metro2.File.stream(header, Stream.map(accounts, &to_base_segment/1))
|> Stream.into(File.stream!("out.metro2"))
|> Stream.run()
```

### Parsing
```elixir
{:ok, file} = Metro2.Parser.parse(File.read!("in.metro2"))
```

### Character Validation
The library enforces METRO 2® character validation rules:
- **Name fields** (surname, first_name, middle_name): Alphanumeric + dashes; apostrophes are removed
- **Address fields** (address_1, address_2, city): Alphanumeric + dots/dashes/slashes; commas, apostrophes and `#` are removed
- **Regular fields**: Alphanumeric only
- **SSN / telephone numbers**: digits, with separators like `123-45-6789` or `(555) 123-4567` removed

All text is upper cased and accented letters are transliterated (`José` → `JOSE`). Control characters such as newlines are rejected. Negative monetary amounts (credit balances) are reported as zero. Dates accept `Date`, `DateTime`, `NaiveDateTime` or ISO 8601 strings; the header's activity and created dates default to today.

### Limitations
- Only the 426-character format is supported, not the 366-byte packed format.
- `Metro2.Rules` covers a subset of the CRRG consistency rules.
- Humanized atom maps for `account_type`, `special_comment` and `consumer_information_indicator` are partial; any code of valid characters is accepted for these.
