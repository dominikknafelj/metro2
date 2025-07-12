defmodule Metro2.BaseTest do
  use ExUnit.Case
  doctest Metro2.Base

  alias Metro2.Base

  describe "account_status_needs_payment_rating?/1" do
    test "returns true for account_transferred (05)" do
      assert Base.account_status_needs_payment_rating?("05")
    end

    test "returns true for closed (13)" do
      assert Base.account_status_needs_payment_rating?("13")
    end

    test "returns true for paid_in_full_foreclosure (65)" do
      assert Base.account_status_needs_payment_rating?("65")
    end

    test "returns true for govt_insurance_claim_filed (88)" do
      assert Base.account_status_needs_payment_rating?("88")
    end

    test "returns true for deed_received (89)" do
      assert Base.account_status_needs_payment_rating?("89")
    end

    test "returns true for foreclosure_completed (94)" do
      assert Base.account_status_needs_payment_rating?("94")
    end

    test "returns true for voluntary_surrender (95)" do
      assert Base.account_status_needs_payment_rating?("95")
    end

    test "returns false for other account statuses" do
      refute Base.account_status_needs_payment_rating?("32")
    end
  end

  describe "alphanumeric_to_metro2/3" do
    @required_length 10
    @permitted_chars ~r/\A([[:alnum:]]|\s)+\z/

    test "returns string with required_length space characters when val is nil" do
      result = Base.alphanumeric_to_metro2(nil, @required_length, @permitted_chars)
      assert result == String.duplicate(" ", @required_length)
    end

    test "returns string with required_length space characters when val is empty string" do
      result = Base.alphanumeric_to_metro2("", @required_length, @permitted_chars)
      assert result == String.duplicate(" ", @required_length)
    end

    test "raises ArgumentError when val contains invalid characters" do
      assert_raise ArgumentError, "Content (Foo%) contains invalid characters", fn ->
        Base.alphanumeric_to_metro2("Foo%", @required_length, @permitted_chars)
      end
    end

    test "slices overflow when val is longer than required length" do
      test_val = String.duplicate("a", @required_length + 1)
      result = Base.alphanumeric_to_metro2(test_val, @required_length, @permitted_chars)
      assert result == String.duplicate("a", @required_length)
    end

    test "pads with trailing spaces when val is shorter than required length" do
      test_val = "x"
      result = Base.alphanumeric_to_metro2(test_val, @required_length, @permitted_chars)
      expected = test_val <> String.duplicate(" ", @required_length - String.length(test_val))
      assert result == expected
      assert String.length(result) == @required_length
    end
  end

  describe "numeric_to_metro2/3" do
    @required_length 9

    test "returns string with required_length zeros when val is nil" do
      result = Base.numeric_to_metro2(nil, @required_length, false)
      assert result == String.duplicate("0", @required_length)
    end

    test "returns string with required_length zeros when val is empty string" do
      result = Base.numeric_to_metro2("", @required_length, false)
      assert result == String.duplicate("0", @required_length)
    end

    test "returns 999999999 when val is too large and is_monetary is true" do
      test_val = 1_000_000_000.78
      result = Base.numeric_to_metro2(test_val, @required_length, true)
      assert result == String.duplicate("9", @required_length)
    end

    test "raises ArgumentError when val is too large and is_monetary is false" do
      test_val = 1_000_000_000.78

      assert_raise ArgumentError,
                   "numeric field (#{test_val}) is too long (max #{@required_length})",
                   fn ->
                     Base.numeric_to_metro2(test_val, @required_length, false)
                   end
    end

    test "returns floored value with leading zeros for valid numeric" do
      test_val = 34.21
      result = Base.numeric_to_metro2(test_val, @required_length, false)
      assert result == "000000034"
    end
  end
end
