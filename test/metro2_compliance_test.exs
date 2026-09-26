defmodule Metro2.ComplianceTest do
  use ExUnit.Case

  alias Metro2.{Fields, File, Parser, ValidationError}

  alias Metro2.Records.{
    BaseSegment,
    J1Segment,
    J2Segment,
    K1Segment,
    K4Segment,
    L1Segment,
    TailerSegment
  }

  defp format(segment, field, value) do
    segment |> Fields.put(field, value) |> Map.fetch!(field) |> Fields.format()
  end

  defp current_account(overrides \\ []) do
    Enum.reduce(
      Keyword.merge(
        [
          account_status: "11",
          consumer_account_number: "A1",
          surname: "Smith",
          social_security_number: "123456789",
          ecoa_code: "1"
        ],
        overrides
      ),
      BaseSegment.new(),
      fn {field, value}, base -> Fields.put(base, field, value) end
    )
  end

  defp serialize_lines(bases) do
    bases
    |> Enum.reduce(File.new(), &File.add_base_segment(&2, &1))
    |> File.serialize()
    |> String.split("\n")
  end

  # 0-based offsets of tailer counters: 11 + 9 * position among the 9-digit fields
  defp tailer_count(tailer, field) do
    index = Enum.find_index(TailerSegment.fields(), &(&1 == field))
    offset = 11 + 9 * (index - 2)
    tailer |> String.slice(offset, 9) |> String.to_integer()
  end

  describe "numeric formatting" do
    test "negative monetary amounts (credit balances) are reported as zero" do
      assert format(BaseSegment.new(), :current_balance, -50) == {:ok, "000000000"}
    end

    test "negative non-monetary numerics are rejected" do
      assert {:error, _} = format(BaseSegment.new(), :correction_indicator, -1)
    end

    test "SSNs and telephone numbers accept separators" do
      base = BaseSegment.new()
      assert format(base, :social_security_number, "012-34-5678") == {:ok, "012345678"}
      assert format(base, :telephone_number, "(555) 123-4567") == {:ok, "5551234567"}
      assert {:error, _} = format(base, :social_security_number, "12A-45-6789")
    end
  end

  describe "text normalization" do
    test "control characters like newlines and tabs are rejected" do
      assert {:error, _} = format(BaseSegment.new(), :surname, "SMITH\nX")
      assert {:error, _} = format(BaseSegment.new(), :surname, "SMITH\tX")
    end

    test "accents are transliterated and text is upper cased" do
      assert {:ok, "JOSE" <> _} = format(BaseSegment.new(), :first_name, "José")
      assert {:ok, "NUNEZ" <> _} = format(BaseSegment.new(), :surname, "Núñez")
    end

    test "apostrophes are removed from names" do
      assert {:ok, "OBRIEN" <> _} = format(BaseSegment.new(), :surname, "O'Brien")
    end

    test "commas and pound signs are removed from addresses" do
      assert {:ok, "12 MAIN ST APT 2" <> _} =
               format(BaseSegment.new(), :address_1, "12 Main St, Apt #2")
    end

    test "postal codes accept ZIP+4 with a dash" do
      assert format(BaseSegment.new(), :postal_code, "33701-1234") == {:ok, "337011234"}
    end
  end

  describe "dates" do
    test "accept Date, DateTime, NaiveDateTime and ISO 8601 strings" do
      base = BaseSegment.new()
      assert format(base, :date_opened, ~D[2024-01-31]) == {:ok, "01312024"}
      assert format(base, :date_opened, ~U[2024-01-31 10:00:00Z]) == {:ok, "01312024"}
      assert format(base, :date_opened, "2024-01-31") == {:ok, "01312024"}
      assert format(base, :time_stamp, ~N[2024-01-31 13:14:15]) == {:ok, "01312024131415"}
      assert {:error, _} = format(base, :date_opened, "31/01/2024")
    end
  end

  describe "code fields" do
    test "accept humanized atoms" do
      assert format(BaseSegment.new(), :account_status, :current) == {:ok, "11"}
      assert format(BaseSegment.new(), :ecoa_code, :delete_consumer) == {:ok, "Z"}
    end

    test "zero pad integer codes" do
      assert format(BaseSegment.new(), :account_status, 5) == {:ok, "05"}
    end

    test "reject codes outside closed code lists" do
      assert {:error, message} = format(BaseSegment.new(), :account_status, "XX")
      assert message =~ "not a valid code"
      assert {:error, _} = format(BaseSegment.new(), :portfolio_type, "Z")
      assert {:error, _} = format(BaseSegment.new(), :account_status, :no_such_status)
    end

    test "terms frequency distinguishes semimonthly from semiannually" do
      assert Metro2.Base.terms_frequency()[:semimonthly] == "E"
      assert Metro2.Base.terms_frequency()[:semiannually] == "S"
    end
  end

  describe "Fields.cast/3" do
    test "validates while setting" do
      assert {:ok, base} = Fields.cast(BaseSegment.new(), :surname, "Smith")
      assert Fields.get(base, :surname) == "Smith"
      assert {:error, "surname: " <> _} = Fields.cast(BaseSegment.new(), :surname, "Sm@th")
    end
  end

  describe "File.validate/1" do
    test "collects every invalid field with its record" do
      file =
        File.new()
        |> File.add_base_segment(current_account())
        |> File.add_base_segment(current_account(surname: "Sm@th", account_status: "XX"))

      assert {:error, errors} = File.validate(file)
      fields = Enum.map(errors, &{&1.record, &1.field})
      assert {{:base, 2}, :surname} in fields
      assert {{:base, 2}, :account_status} in fields
      refute Enum.any?(errors, &(&1.record == {:base, 1}))
    end

    test "checks cross-field rules" do
      cases = [
        {[account_status: nil], :account_status},
        {[account_status: "13"], :payment_rating},
        {[account_status: "71", amount_past_due: 100], :first_delinquency_date},
        {[account_status: "71", first_delinquency_date: ~D[2024-01-01]], :amount_past_due},
        {[amount_past_due: 100], :amount_past_due},
        {[account_status: "13", payment_rating: "0", current_balance: 10], :current_balance},
        {[payment_history_profile: "000000000000000000000009"], :payment_history_profile}
      ]

      for {overrides, field} <- cases do
        file = File.add_base_segment(File.new(), current_account(overrides))
        assert {:error, errors} = File.validate(file), inspect(overrides)
        assert Enum.any?(errors, &(&1.field == field)), inspect({overrides, errors})
      end
    end

    test "validates appended segments" do
      base = BaseSegment.add_segment(current_account(), Fields.put(J1Segment.new(), :surname, "@"))

      assert {:error, [%{segment: :j1, field: :surname}]} =
               File.validate(File.add_base_segment(File.new(), base))
    end

    test "serialize/1 raises ValidationError listing all errors" do
      file = File.add_base_segment(File.new(), current_account(surname: "Sm@th", state: "N%"))

      error = assert_raise ValidationError, fn -> File.serialize(file) end
      assert length(error.errors) == 2
      assert Exception.message(error) =~ "base record 1 surname"
    end
  end

  describe "serialization" do
    test "base segments are written in insertion order" do
      [_, first, second, _] =
        serialize_lines([
          current_account(consumer_account_number: "FIRST"),
          current_account(consumer_account_number: "SECOND")
        ])

      assert String.slice(first, 42, 5) == "FIRST"
      assert String.slice(second, 42, 6) == "SECOND"
    end

    test "header activity and created dates default to today" do
      [header | _] = serialize_lines([])
      today = Calendar.strftime(Date.utc_today(), "%m%d%Y")
      assert String.slice(header, 47, 16) == today <> today
    end

    test "appended segments extend the record and its descriptor word" do
      base =
        current_account()
        |> BaseSegment.add_segment(Fields.put(J1Segment.new(), :surname, "Doe"))
        |> BaseSegment.add_segment(K1Segment.new() |> Fields.put(:original_creditor_name, "ACME"))

      [_, record, _] = serialize_lines([base])
      assert String.length(record) == 426 + 100 + 34
      assert String.starts_with?(record, "0560")
      assert String.slice(record, 426, 5) == "J1 DO"
      assert String.slice(record, 526, 6) == "K1ACME"
    end
  end

  describe "tailer" do
    test "counts statuses, identifiers, ECOA Z and appended segments" do
      j1 =
        J1Segment.new()
        |> Fields.put(:social_security_number, "111223333")
        |> Fields.put(:ecoa_code, "Z")

      bases = [
        current_account(date_of_birth: ~D[1980-01-01], telephone_number: "5551234567")
        |> BaseSegment.add_segment(j1),
        current_account(
          account_status: 5,
          payment_rating: "0",
          ecoa_code: "Z",
          social_security_number: nil
        ),
        current_account(account_status: "DA")
      ]

      tailer = bases |> serialize_lines() |> List.last()

      assert String.slice(tailer, 4, 7) == "TRAILER"
      assert tailer_count(tailer, :total_base_records) == 3
      assert tailer_count(tailer, :total_status_code_11) == 1
      assert tailer_count(tailer, :total_status_code_05) == 1
      assert tailer_count(tailer, :total_status_code_da) == 1
      assert tailer_count(tailer, :ecoa_code_z) == 2
      assert tailer_count(tailer, :total_social_security_numbers) == 3
      assert tailer_count(tailer, :total_social_security_numbers_in_base) == 2
      assert tailer_count(tailer, :total_social_security_numbers_in_j1) == 1
      assert tailer_count(tailer, :total_date_of_births) == 1
      assert tailer_count(tailer, :total_date_of_births_in_base) == 1
      assert tailer_count(tailer, :total_telephone_numbers) == 1
      assert tailer_count(tailer, :total_j1_segments) == 1
    end
  end

  describe "File.stream/2" do
    test "produces the same output as serialize/1 from a lazy enumerable" do
      bases = [
        current_account(consumer_account_number: "S1"),
        current_account(consumer_account_number: "S2")
      ]

      file = Enum.reduce(bases, File.new(), &File.add_base_segment(&2, &1))

      streamed = file.header |> File.stream(Stream.map(bases, & &1)) |> Enum.join()
      assert streamed == File.serialize(file)
    end

    test "raises on an invalid record while streaming" do
      stream = File.stream(File.new().header, [current_account(), current_account(surname: "@")])

      error = assert_raise ValidationError, fn -> Stream.run(stream) end
      assert [%{record: {:base, 2}, field: :surname}] = error.errors
    end
  end

  describe "Parser" do
    test "round trips a file with every appended segment type" do
      base =
        current_account(date_opened: ~D[2020-02-29], current_balance: 1234, postal_code: "33701")
        |> BaseSegment.add_segment(Fields.put(J1Segment.new(), :surname, "DOE"))
        |> BaseSegment.add_segment(Fields.put(J2Segment.new(), :city, "TAMPA"))
        |> BaseSegment.add_segment(Fields.put(K1Segment.new(), :original_creditor_name, "ACME"))
        |> BaseSegment.add_segment(Fields.put(K4Segment.new(), :balloon_payment_amount, 500))
        |> BaseSegment.add_segment(Fields.put(L1Segment.new(), :change_indicator, "1"))

      content = serialize_lines([base, current_account()]) |> Enum.join("\n")

      assert {:ok, parsed} = Parser.parse(content)
      assert File.serialize(parsed) == content

      [first, _] = Enum.reverse(parsed.base_segments)
      assert Fields.get(first, :date_opened) == ~D[2020-02-29]
      assert Fields.get(first, :current_balance) == 1234
      assert Fields.get(first, :surname) == "SMITH"
      assert [%J1Segment{}] = first.j1
      assert Fields.get(first.k4, :balloon_payment_amount) == 500
    end

    test "reports the line of malformed records" do
      [header, base, tailer] = serialize_lines([current_account()])
      bad = String.slice(base, 0, 100)

      assert {:error, "line 2: " <> _} = Parser.parse(Enum.join([header, bad, tailer], "\n"))
      assert {:error, "missing TRAILER record"} = Parser.parse(Enum.join([header, base], "\n"))
    end
  end
end
