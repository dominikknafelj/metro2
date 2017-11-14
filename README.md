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
  [{:metro_2, "~> 0.1.0"}]
end
```

## Usage
Every Segment stuct contains field structs, which contains field structs.
Those field structs bear information about the individual field length, type and the allowed characters, wich are important for the
serialisation process. 

To access a field value in a segment struct, please use i.E.:
```elixir
# setter
%Metro2.Records.BaseSegment{}
|> Metro2.Fields.put(:first_name, "Max")

# getter
%Metro2.Records.BaseSegment{}
|> Metro2.Fields.get(:first_name)
```
### METRO 2® File Structure
The Metro2 File Structure is the root structure and it has the following inital structure:
```elixir
defstruct [
    header: %HeaderSegment{},
    base_segments: [],
    tailer: %TailerSegment{}
  ]
```
This file can be converted into a serialized Metro2 string via:

```elixir
my_file = %Metro2.File{}
# update header segment
# add base segments
my_file |> Metro2.File.serialize
```
### Header Segment
The header segment contains information about the data furnisher.
You should simply transform the header segment structure in the file structure.

### Base Segment
The base segment is stored in a list in the Metro2.File structure. Each Base segment represents one reportable loan.
```elixir
base_segment =v%Metro2.Records.BaseSegment{}
#
# add information to the base_segment
#
%Metro2.File{}
|> Metro2.File.add_base_segment(base_segment)
```
### Tailer Segment
The tailer segment contains counters for metrics like the SSN and the account statuses.
It will be completly autogenerated.

### Limitations
The Metro2 Standard contains beside the base segment( which is the most common one) a coule of special segments, which are not supported yet.

