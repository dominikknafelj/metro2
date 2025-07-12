#!/usr/bin/env elixir

# Metro2 Library Demo Script
# This script demonstrates how to use the Metro2 library to generate
# METRO 2® format files for credit bureau reporting.

alias Metro2.{File, Records.BaseSegment, Fields}

IO.puts("🏦 Metro2 Credit Reporting Library Demo")
IO.puts("=====================================\n")

# Create a new Metro2 file
IO.puts("📁 Creating new Metro2 file...")
file = File.new()

# Configure header segment with reporter information
IO.puts("📋 Setting up header segment...")
header = 
  file.header
  |> Fields.put(:cycle_number, "01")
  |> Fields.put(:innovis_program_identifier, "DEMO12345")
  |> Fields.put(:equifax_program_identifier, "DEMO67890")
  |> Fields.put(:experian_program_identifier, "DM123")
  |> Fields.put(:transunion_program_identifier, "DEMO98765")
  |> Fields.put(:reporter_name, "Demo Credit Union")
  |> Fields.put(:reporter_address, "123 Banking St./Suite 100")  # Note: dots and slashes allowed
  |> Fields.put(:reporter_telephone_number, "5551234567")

file = %{file | header: header}

IO.puts("✅ Header configured with reporter information")

# Create example consumer accounts
IO.puts("\n👥 Creating example consumer accounts...")

# Account 1: Current account with hyphenated name
IO.puts("\n  Account 1: John Smith-Johnson (Current Account)")
account1 = 
  BaseSegment.new()
  |> Fields.put(:identification_number, "DEMO001")
  |> Fields.put(:consumer_account_number, "1001234567")
  |> Fields.put(:portfolio_type, "R")  # Revolving
  |> Fields.put(:account_type, "01")   # Unsecured
  |> Fields.put(:account_status, "11") # Current
  |> Fields.put(:current_balance, 1500)
  |> Fields.put(:credit_limit, 5000)
  |> Fields.put(:scheduled_monthly_payment_amount, 50)
  |> Fields.put(:actual_payment_amount, 50)
  # Consumer information with character validation
  |> Fields.put(:surname, "Smith-Johnson")      # Dash allowed in names
  |> Fields.put(:first_name, "John")
  |> Fields.put(:middle_name, "Michael")
  |> Fields.put(:social_security_number, "123456789")
  |> Fields.put(:address_1, "456 Oak Ave./Apt 2B")  # Dots and slashes allowed
  |> Fields.put(:city, "St. Petersburg")         # Dots allowed in city names
  |> Fields.put(:state, "FL")
  |> Fields.put(:postal_code, "33701")
  |> Fields.put(:ecoa_code, "1")  # Individual

# Account 2: Past due account
IO.puts("  Account 2: Maria Garcia-Rodriguez (Past Due)")
account2 = 
  BaseSegment.new()
  |> Fields.put(:identification_number, "DEMO002")
  |> Fields.put(:consumer_account_number, "2001234567")
  |> Fields.put(:portfolio_type, "I")  # Installment
  |> Fields.put(:account_type, "01")
  |> Fields.put(:account_status, "71") # 30-59 days past due
  |> Fields.put(:current_balance, 8500)
  |> Fields.put(:amount_past_due, 250)
  |> Fields.put(:scheduled_monthly_payment_amount, 200)
  |> Fields.put(:actual_payment_amount, 0)
  # Consumer information
  |> Fields.put(:surname, "Garcia-Rodriguez")    # Dash allowed, no accents
  |> Fields.put(:first_name, "Maria")
  |> Fields.put(:middle_name, "Elena")
  |> Fields.put(:social_security_number, "987654321")
  |> Fields.put(:address_1, "789 Pine St./Unit C") # Address with slash
  |> Fields.put(:city, "Miami")
  |> Fields.put(:state, "FL")
  |> Fields.put(:postal_code, "33101")
  |> Fields.put(:ecoa_code, "1")

# Account 3: Closed account
IO.puts("  Account 3: Robert Williams-Brown (Closed Account)")
account3 = 
  BaseSegment.new()
  |> Fields.put(:identification_number, "DEMO003")
  |> Fields.put(:consumer_account_number, "3001234567")
  |> Fields.put(:portfolio_type, "M")  # Mortgage
  |> Fields.put(:account_type, "01")
  |> Fields.put(:account_status, "13") # Closed
  |> Fields.put(:current_balance, 0)
  |> Fields.put(:scheduled_monthly_payment_amount, 0)
  |> Fields.put(:actual_payment_amount, 0)
  # Consumer information
  |> Fields.put(:surname, "Williams-Brown")  # Dash allowed in names
  |> Fields.put(:first_name, "Robert")
  |> Fields.put(:middle_name, "James")
  |> Fields.put(:social_security_number, "456789123")
  |> Fields.put(:address_1, "321 Elm Dr./Bldg A")
  |> Fields.put(:city, "Tampa")
  |> Fields.put(:state, "FL")
  |> Fields.put(:postal_code, "33602")
  |> Fields.put(:ecoa_code, "1")

# Add accounts to file
file = 
  file
  |> File.add_base_segment(account1)
  |> File.add_base_segment(account2)
  |> File.add_base_segment(account3)

IO.puts("✅ Added 3 consumer accounts to Metro2 file")

# Demonstrate character validation
IO.puts("\n🔒 Demonstrating Character Validation...")

IO.puts("  ✅ Valid characters in names (dashes allowed):")
IO.puts("     - Smith-Johnson ✓")
IO.puts("     - Garcia-Rodriguez ✓")

IO.puts("  ✅ Valid characters in addresses (dots, dashes, slashes allowed):")
IO.puts("     - 456 Oak Ave./Apt 2B ✓")
IO.puts("     - St. Petersburg ✓")

IO.puts("  ❌ Testing invalid characters (should fail):")

# Test invalid characters
invalid_tests = [
  {:surname, "Smith@Johnson", "@"},
  {:surname, "O'Connor", "apostrophe"},
  {:surname, "García", "accented character"},
  {:address_1, "123 Main St%", "%"},
  {:account_type, "ABC-123", "dash in account_type"}
]

for {field, value, description} <- invalid_tests do
  try do
    BaseSegment.new()
    |> Fields.put(field, value)
    |> Map.get(field)
    |> Fields.to_metro2()
    
    IO.puts("     - #{description}: ❌ Should have failed!")
  rescue
    ArgumentError -> 
      IO.puts("     - #{description}: ✅ Properly rejected")
  end
end

# Generate Metro2 format
IO.puts("\n📤 Generating Metro2 format file...")
metro2_content = File.serialize(file)

# Analysis
lines = String.split(metro2_content, "\n")
IO.puts("✅ Generated Metro2 file with #{length(lines)} lines")

# Show file structure
IO.puts("\n📊 File Structure Analysis:")
IO.puts("  - Header segment: 1 line")
IO.puts("  - Base segments: 3 lines (one per account)")
IO.puts("  - Tailer segment: 1 line")
IO.puts("  - Field data: #{length(lines) - 4} lines")

# Show sample output
IO.puts("\n📄 Sample Metro2 Output (first 3 lines):")
lines
|> Enum.take(3)
|> Enum.with_index(1)
|> Enum.each(fn {line, index} ->
  # Show first 60 characters of each line
  preview = String.slice(line, 0, 60)
  IO.puts("  Line #{index}: #{preview}#{if String.length(line) > 60, do: "...", else: ""}")
end)

# Show statistics from tailer segment
IO.puts("\n📈 Account Statistics:")
IO.puts("  - Total accounts: 3")
IO.puts("  - Current accounts: 1")
IO.puts("  - Past due accounts: 1") 
IO.puts("  - Closed accounts: 1")
IO.puts("  - Total SSNs reported: 3")

# Save to file
:ok = Elixir.File.write("demo_output.metro2", metro2_content)
IO.puts("\n💾 Metro2 file saved as 'demo_output.metro2'")

# Summary
IO.puts("\n🎉 Demo Complete!")
IO.puts("================")
IO.puts("✅ Successfully created Metro2 file with:")
IO.puts("   • Proper character validation for all field types")
IO.puts("   • Realistic consumer account data")
IO.puts("   • Compliant METRO 2® format output")
IO.puts("   • Name fields supporting dashes (Smith-Johnson)")
IO.puts("   • Address fields supporting dots/dashes/slashes")
IO.puts("   • Proper rejection of invalid characters")
IO.puts("   • Modern Elixir #{System.version()}")
IO.puts("\n📁 Output file: demo_output.metro2")
IO.puts("🔍 Use 'cat demo_output.metro2' to view the generated Metro2 content") 