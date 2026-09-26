# Metro2 Library Demo

This demo showcases the Metro2 library's functionality with realistic example data for credit bureau reporting.

## What the Demo Shows

- **Character Validation**: Demonstrates proper validation for different field types:
  - Name fields (surname, first_name, middle_name) accept alphanumeric + dashes
  - Address fields accept alphanumeric + dots/dashes/slashes  
  - Regular fields accept only alphanumeric characters
  - Invalid characters are properly rejected; apostrophes, accents, commas and `#` are normalized

- **Realistic Data**: Creates 3 consumer accounts with different scenarios:
  - Account 1: John Smith-Johnson (Current account)
  - Account 2: Maria Garcia-Rodriguez (Past due account)
  - Account 3: Robert Williams-Brown (Closed account)

- **METRO 2® Format**: Generates compliant METRO 2® format output with:
  - Header segment with reporter information
  - Base segments for each consumer account
  - Tailer segment with statistics
  - Proper field formatting and validation

## How to Run

### Using Mix (Recommended)
```bash
mix run demo.exs
```

### Using Elixir directly
```bash
elixir demo.exs
```

## Expected Output

The demo will:
1. Create a Metro2 file structure
2. Add realistic consumer account data
3. Demonstrate character validation (both valid and invalid examples)
4. Generate a Metro2 format file
5. Save the output to `demo_output.metro2`
6. Display statistics and analysis

## Output Files

- `demo_output.metro2` - The generated METRO 2® format file
- Console output with detailed progress and validation examples

## Example Data Features

- **Hyphenated Names**: Smith-Johnson, Garcia-Rodriguez, Williams-Brown
- **Complex Addresses**: Street addresses with dots, slashes, and unit numbers
- **Different Account Types**: Revolving, Installment, Mortgage
- **Various Account Statuses**: Current, Past Due, Closed
- **Proper SSN and Contact Information**

## Key Validation Examples

✅ **Valid Characters:**
- Names: `Smith-Johnson` (dash allowed)
- Addresses: `456 Oak Ave./Apt 2B` (dots and slashes allowed)
- Cities: `St. Petersburg` (dots allowed)

🔄 **Normalized automatically:**
- Names: `O'Connor` → `OCONNOR` (apostrophes removed)
- Names: `García` → `GARCIA` (accents transliterated, text upper cased)
- Addresses: `12 Main St, Apt #2` → `12 MAIN ST APT 2` (commas and `#` removed)

❌ **Invalid values (properly rejected):**
- Names: `Smith@Johnson` (@ not allowed)
- Names: `Smith\nJohnson` (control characters not allowed)
- Account status: `XX` (not a valid status code)
- Addresses: `123 Main St%` (% not allowed)
- Account Types: `ABC-123` (dash not allowed in regular fields)

## Requirements

- Elixir 1.14+
- Mix dependencies installed (`mix deps.get`)
- Metro2 library compiled

This demo validates that the library correctly handles METRO 2® format requirements and character validation rules. 