# Metro2
This library follows the METRO 2 ® data reporting format, which is a data reporting format for consumer credit account data furnishers.

It contains structs for 
 * header segments
 * base segments
 * tailer segments

 A port from the [Ruby implementation](https://github.com/teamupstart/metro_2)

## Installation

```elixir
def deps do
  [{:metro_2, "~> 0.2.0"}]
end
```

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

**Output**: Creates `demo_output.metro2` with 200+ lines of properly formatted METRO 2® data.

For detailed demo documentation, see [README_DEMO.md](README_DEMO.md).

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

### Character Validation
The library enforces METRO 2® character validation rules:
- **Name fields** (surname, first_name, middle_name): Alphanumeric + dashes
- **Address fields** (address_1, address_2, city): Alphanumeric + dots/dashes/slashes  
- **Regular fields**: Alphanumeric only

### Limitations
The Metro2 Standard contains, besides the base segment (which is the most common one), a couple of special segments which are not supported yet.

