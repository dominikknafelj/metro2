defmodule Metro2.FieldValidationTest do
  use ExUnit.Case

  alias Metro2.{Fields, Records.BaseSegment}

  describe "character validation for different field types" do
    test "surname field accepts alphanumeric characters and dashes" do
      base_segment = BaseSegment.new()

      # Valid names with dashes should work
      valid_names = ["John-Smith", "Mary-Jane", "Jean-Luc", "O'Connor-Smith"]

      for name <- valid_names do
        updated_segment = Fields.put(base_segment, :surname, name)
        assert Fields.get(updated_segment, :surname) == name
      end
    end

    test "surname field rejects invalid characters" do
      base_segment = BaseSegment.new()

      # Invalid characters should raise an error during serialization
      invalid_names = ["John@Smith", "Mary.Jane", "Jean/Luc", "O'Connor%Smith"]

      for name <- invalid_names do
        updated_segment = Fields.put(base_segment, :surname, name)

        assert_raise ArgumentError, fn ->
          Fields.to_metro2(updated_segment.surname)
        end
      end
    end

    test "first_name field accepts alphanumeric characters and dashes" do
      base_segment = BaseSegment.new()

      # Valid names with dashes should work
      valid_names = ["Mary-Jane", "Jean-Luc", "Ann-Marie"]

      for name <- valid_names do
        updated_segment = Fields.put(base_segment, :first_name, name)
        assert Fields.get(updated_segment, :first_name) == name
      end
    end

    test "first_name field rejects invalid characters" do
      base_segment = BaseSegment.new()

      # Invalid characters should raise an error during serialization
      invalid_names = ["Mary@Jane", "Jean.Luc", "Ann/Marie"]

      for name <- invalid_names do
        updated_segment = Fields.put(base_segment, :first_name, name)

        assert_raise ArgumentError, fn ->
          Fields.to_metro2(updated_segment.first_name)
        end
      end
    end

    test "address fields accept alphanumeric characters plus dots, dashes, and slashes" do
      base_segment = BaseSegment.new()

      # Valid addresses with allowed special characters
      valid_addresses = [
        "123 Main St.",
        "456 Oak Ave-Unit 2",
        "789 Pine St./Apt 3B",
        "1010 Elm Dr. Unit A-1"
      ]

      for address <- valid_addresses do
        updated_segment = Fields.put(base_segment, :address_1, address)
        assert Fields.get(updated_segment, :address_1) == address
      end
    end

    test "address fields reject invalid characters" do
      base_segment = BaseSegment.new()

      # Invalid characters should raise an error during serialization
      invalid_addresses = [
        "123 Main St@",
        "456 Oak Ave#2",
        "789 Pine St%",
        "1010 Elm Dr&"
      ]

      for address <- invalid_addresses do
        updated_segment = Fields.put(base_segment, :address_1, address)

        assert_raise ArgumentError, fn ->
          Fields.to_metro2(updated_segment.address_1)
        end
      end
    end

    test "city field accepts alphanumeric characters plus dots, dashes, and slashes" do
      base_segment = BaseSegment.new()

      # Valid city names with allowed special characters
      valid_cities = [
        "New York",
        "Los Angeles",
        "St. Petersburg",
        "Grand-Rapids",
        "Washington/DC"
      ]

      for city <- valid_cities do
        updated_segment = Fields.put(base_segment, :city, city)
        assert Fields.get(updated_segment, :city) == city
      end
    end

    test "regular alphanumeric fields only accept alphanumeric characters" do
      base_segment = BaseSegment.new()

      # Valid alphanumeric values
      valid_values = ["ABC123", "XYZ789", "Test123"]

      for value <- valid_values do
        updated_segment = Fields.put(base_segment, :account_type, value)
        assert Fields.get(updated_segment, :account_type) == value
      end
    end

    test "regular alphanumeric fields reject special characters" do
      base_segment = BaseSegment.new()

      # Invalid characters should raise an error during serialization
      invalid_values = ["ABC@123", "XYZ-789", "Test.123"]

      for value <- invalid_values do
        updated_segment = Fields.put(base_segment, :account_type, value)

        assert_raise ArgumentError, fn ->
          Fields.to_metro2(updated_segment.account_type)
        end
      end
    end

    test "field serialization produces correctly formatted output" do
      base_segment = BaseSegment.new()

      # Test surname (should allow dashes)
      updated_segment = Fields.put(base_segment, :surname, "Smith-Jones")
      surname_field = updated_segment.surname

      # Should serialize without error
      serialized = Fields.to_metro2(surname_field)
      assert is_binary(serialized)
      # surname field length
      assert String.length(serialized) == 25

      # Test address (should allow dots, dashes, slashes)
      updated_segment = Fields.put(base_segment, :address_1, "123 Main St./Apt 2-A")
      address_field = updated_segment.address_1

      # Should serialize without error
      serialized = Fields.to_metro2(address_field)
      assert is_binary(serialized)
      # address_1 field length
      assert String.length(serialized) == 32
    end

    test "field types have correct permitted_chars patterns" do
      base_segment = BaseSegment.new()

      # Check that name fields use the dash pattern (by testing functionality)
      assert Regex.match?(base_segment.surname.permitted_chars, "John-Smith")
      assert Regex.match?(base_segment.first_name.permitted_chars, "Mary-Jane")
      assert Regex.match?(base_segment.middle_name.permitted_chars, "Jean-Luc")

      # Check that address fields use the dot-dash-slash pattern (by testing functionality)
      assert Regex.match?(base_segment.address_1.permitted_chars, "123 Main St./Apt 2-A")
      assert Regex.match?(base_segment.address_2.permitted_chars, "456 Oak Ave-Unit 2")
      assert Regex.match?(base_segment.city.permitted_chars, "St. Petersburg")

      # Check that regular fields use the standard alphanumeric pattern (by testing functionality)
      assert Regex.match?(base_segment.account_type.permitted_chars, "ABC123")
      assert Regex.match?(base_segment.state.permitted_chars, "NY")

      # Verify that patterns reject invalid characters
      refute Regex.match?(base_segment.surname.permitted_chars, "John@Smith")
      refute Regex.match?(base_segment.address_1.permitted_chars, "123 Main St@")
      refute Regex.match?(base_segment.account_type.permitted_chars, "ABC-123")
    end
  end
end
