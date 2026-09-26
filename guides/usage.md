# Usage

This guide walks through producing a METRO 2® file: building the header, adding accounts,
validating, and writing the output. For what each segment and field means, see the
[Segments](segments.md) guide.

## The building blocks

- `Metro2.File` holds a header, the base segments and (computed) tailer.
- Segments are structs whose fields hold typed field structs. **Always create them with
  `new/0`** (`Metro2.Records.BaseSegment.new()`); a bare `%BaseSegment{}` has no field
  definitions.
- Read and write values with `Metro2.Fields.put/3` and `Metro2.Fields.get/2`.

```elixir
alias Metro2.Fields
alias Metro2.Records.BaseSegment

base = BaseSegment.new() |> Fields.put(:surname, "Smith")
Fields.get(base, :surname)
#=> "Smith"
```

`put/3` stores the value as given. Normalization and validation happen when the file is
validated or serialized, or immediately with `Fields.cast/3`.

## 1. Set up the header

```elixir
file = Metro2.File.new()

header =
  file.header
  |> Fields.put(:equifax_program_identifier, "EQ12345")
  |> Fields.put(:experian_program_identifier, "EX123")
  |> Fields.put(:transunion_program_identifier, "TU12345")
  |> Fields.put(:reporter_name, "Demo Credit Union")
  |> Fields.put(:reporter_address, "123 Banking St./Suite 100")
  |> Fields.put(:reporter_telephone_number, "(555) 123-4567")
  |> Fields.put(:activity_date, ~D[2026-08-31])

file = %{file | header: header}
```

`activity_date` and `created_date` default to the current date when left unset.

## 2. Add accounts

One base segment per account. Code fields accept the METRO 2® code or the humanized atom
from `Metro2.Base`.

```elixir
account =
  BaseSegment.new()
  |> Fields.put(:identification_number, "DEMO001")
  |> Fields.put(:consumer_account_number, "1001234567")
  |> Fields.put(:portfolio_type, :revolving)         # "R"
  |> Fields.put(:account_type, "18")
  |> Fields.put(:date_opened, ~D[2021-03-15])
  |> Fields.put(:credit_limit, 5000)
  |> Fields.put(:terms_duration, "REV")
  |> Fields.put(:terms_frequency, :monthly)          # "M"
  |> Fields.put(:scheduled_monthly_payment_amount, 50)
  |> Fields.put(:actual_payment_amount, 50)
  |> Fields.put(:account_status, :current)           # "11"
  |> Fields.put(:payment_history_profile, "000000000000BBBBBBBBBBBB")
  |> Fields.put(:current_balance, 1500)
  |> Fields.put(:account_information_date, ~D[2026-08-31])
  |> Fields.put(:surname, "Smith-Johnson")
  |> Fields.put(:first_name, "John")
  |> Fields.put(:social_security_number, "123-45-6789")
  |> Fields.put(:date_of_birth, ~D[1985-06-01])
  |> Fields.put(:ecoa_code, :individual)             # "1"
  |> Fields.put(:address_1, "456 Oak Ave., Apt #2B")
  |> Fields.put(:city, "St. Petersburg")
  |> Fields.put(:state, "FL")
  |> Fields.put(:postal_code, "33701-1234")

file = Metro2.File.add_base_segment(file, account)
```

Accounts are written in the order they are added.

### What gets normalized

You can pass values as they come from your system; on output:

- text is upper cased and accents are transliterated (`José` → `JOSE`)
- apostrophes are removed from names (`O'Brien` → `OBRIEN`)
- commas, apostrophes and `#` are removed from addresses (`Apt #2B` → `APT 2B`)
- separators are removed from SSNs, telephone numbers and ZIP+4 codes
- amounts are floored to whole dollars; negative amounts (credit balances) become 0
- dates may be `Date`, `DateTime`, `NaiveDateTime` or ISO 8601 strings (`"2026-08-31"`)
- integers in code fields are zero padded (`account_status: 5` → `"05"`)

Anything else outside the permitted characters (e.g. `@`, `%`, newlines) or outside a
closed code list is an error.

## 3. Common account scenarios

These cover the cross-field rules the library checks (see `Metro2.Rules`).

**Past due** — needs an amount past due and the date of first delinquency:

```elixir
past_due =
  account
  |> Fields.put(:account_status, :past_due_30_59)    # "71"
  |> Fields.put(:amount_past_due, 250)
  |> Fields.put(:first_delinquency_date, ~D[2026-07-01])
```

**Paid and closed** — zero balance, a closed date, and the payment rating the account had
when it was closed:

```elixir
closed =
  account
  |> Fields.put(:account_status, :closed)            # "13"
  |> Fields.put(:payment_rating, :current)           # "0"
  |> Fields.put(:current_balance, 0)
  |> Fields.put(:closed_date, ~D[2026-08-15])
```

**Charged off**:

```elixir
charged_off =
  account
  |> Fields.put(:account_status, :charge_off)        # "97"
  |> Fields.put(:original_charge_off_amount, 4200)
  |> Fields.put(:amount_past_due, 4200)
  |> Fields.put(:first_delinquency_date, ~D[2025-11-01])
```

**Joint account** — the co-borrower goes in a J1 segment (same address) or J2 segment
(different address), and both consumers get an ECOA code:

```elixir
alias Metro2.Records.J1Segment

co_borrower =
  J1Segment.new()
  |> Fields.put(:surname, "Smith-Johnson")
  |> Fields.put(:first_name, "Jane")
  |> Fields.put(:social_security_number, "987654321")
  |> Fields.put(:ecoa_code, :joint_contractual_liability)   # "2"

joint =
  account
  |> Fields.put(:ecoa_code, :joint_contractual_liability)
  |> BaseSegment.add_segment(co_borrower)
```

**Account number changed** — report the new number in the base segment and the change in
an L1 segment:

```elixir
alias Metro2.Records.L1Segment

renumbered =
  account
  |> BaseSegment.add_segment(
    L1Segment.new()
    |> Fields.put(:change_indicator, "1")
    |> Fields.put(:new_consumer_account_number, "2009876543")
  )
```

**Delete an account** from the bureaus' files: `account_status: :delete_account` (DA), or
`:delete_account_fraud` (DF) for fraud.

## 4. Validate

`Metro2.File.validate/1` checks every field of every record plus the cross-field rules, and
returns all problems at once:

```elixir
case Metro2.File.validate(file) do
  :ok ->
    :ok

  {:error, errors} ->
    for %{record: record, segment: segment, field: field, message: message} <- errors do
      IO.puts("#{inspect(record)} #{segment}.#{field}: #{message}")
    end
end
```

`record` is `:header` or `{:base, n}` (1-based, in the order accounts were added), so you
can map errors back to your source rows. To check one value as you set it, use
`Metro2.Fields.cast/3`:

```elixir
{:error, "surname: Content (SM@TH) contains invalid characters"} =
  Fields.cast(BaseSegment.new(), :surname, "Sm@th")
```

## 5. Write the file

For files that fit in memory:

```elixir
content = Metro2.File.serialize(file)
File.write!("2026-08.metro2", content)
```

`serialize/1` raises `Metro2.ValidationError` (listing every error) if the file is invalid.

For large portfolios, stream: accounts are converted, validated and written one at a time,
and the tailer is accumulated along the way.

```elixir
accounts = [account, past_due, closed]   # or any Enumerable, e.g. a lazy DB stream

header
|> Metro2.File.stream(Stream.map(accounts, & &1))
|> Stream.into(File.stream!("2026-08.metro2"))
|> Stream.run()
```

An invalid record raises `Metro2.ValidationError` while the stream is consumed.

## 6. Read a file

```elixir
{:ok, parsed} = Metro2.Parser.parse(File.read!("2026-08.metro2"))

[first | _] = Enum.reverse(parsed.base_segments)   # stored newest-first
Fields.get(first, :current_balance)
#=> 1500
```

Parsed values are as written in the file: upper-case text, integers for amounts, `Date`
and `NaiveDateTime` for dates. Serializing a parsed file reproduces it.
