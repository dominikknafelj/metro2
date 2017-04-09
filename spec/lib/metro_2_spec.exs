require IEx;
defmodule Metro2Spec do
  use ESpec

  example_group do
    describe "Metro2.account_status_needs_payment_rating?", focus: true do
      it "returns true when account_transferred: 05 " do
        expect(described_module().account_status_needs_payment_rating?("05")).to be_truthy()
      end
      it "returns true when closed: 13 " do
        expect(described_module().account_status_needs_payment_rating?("13")).to be_truthy()
      end
      it "returns true when paid_in_full_foreclosure: 65 " do
        expect(described_module().account_status_needs_payment_rating?("65")).to be_truthy()
      end
      it "govt_insurance_claim_filed: 88 " do
        expect(described_module().account_status_needs_payment_rating?("88")).to be_truthy()
      end
      it "returns true when deed_received: 89 " do
        expect(described_module().account_status_needs_payment_rating?("89")).to be_truthy()
      end
      it "returns true when foreclosure_completed: 94 " do
        expect(described_module().account_status_needs_payment_rating?("94")).to be_truthy()
      end
      it "returns true when voluntary_surrender: 95 " do
        expect(described_module().account_status_needs_payment_rating?("95")).to be_truthy()
      end
      it "returns false when account_transferred: anything other " do
        expect(described_module().account_status_needs_payment_rating?("32")).to be_falsy()
      end
    end

    describe "Metro2.alphanumeric_to_metro2", focus: true do
      before required_length: 10, permitted_chars: ~r/\A([[:alnum:]]|\s)+\z/, name: "Foo"
      it "returns an string with required_length space characters when val = nil " do
        expect(described_module().alphanumeric_to_metro2(nil, shared.required_length, shared.permitted_chars, shared.name ))
        |> to(eq(String.duplicate(" ", shared.required_length)))
      end

      it "returns an string with required_length space characters when val = nil " do
        expect(described_module().alphanumeric_to_metro2("", shared.required_length, shared.permitted_chars, shared.name ))
        |> to(eq(String.duplicate(" ", shared.required_length)))
      end

      context "val contains an invalid character" do
        it "raises an ArgumentError exception" do
          expect( fn-> described_module().alphanumeric_to_metro2("Foo%", shared.required_length, shared.permitted_chars, shared.name) end)
          |> to(raise_exception ArgumentError,"Content (Foo%) contains invalid characters in field '#{shared.name}'")
        end
      end

      context "val is a valid string" do
        context "val's size is longer than the required length" do
          it "slices of the overhead at the end of the string" do
            test_val = "a" |> String.duplicate(shared.required_length + 1 )
            expect(described_module().alphanumeric_to_metro2(test_val, shared.required_length, shared.permitted_chars, shared.name))
            |> to(eq(String.duplicate( "a" ,shared.required_length)))
          end
        end

        context " val is less or equal than the required length" do
          it "returns a string with the length equals the required length" do
            test_val = "x"
            expect(described_module().alphanumeric_to_metro2(test_val, shared.required_length, shared.permitted_chars, shared.name)
                   |> String.length
            )
            |> to(eq shared.required_length)
          end

          it "returns the val with trailing spaces as fillup" do
            test_val = "x"
            result_string = test_val <>  (" " |> String.duplicate( shared.required_length - String.length(test_val)))
            expect(described_module().alphanumeric_to_metro2(test_val, shared.required_length, shared.permitted_chars, shared.name)
            )
            |> to(eq result_string)
          end
        end
      end
    end

    describe "Metro2.numeric_to_metro2", focus: true do
      before required_length: 9
      it "returns an string with required_length space characters when val = nil " do
        expect(described_module().numeric_to_metro2(nil, shared.required_length, false ))
        |> to(eq(String.duplicate("0", shared.required_length)))
      end

      it "returns an string with required_length space characters when val = nil " do
        expect(described_module().numeric_to_metro2("", shared.required_length, false ))
        |> to(eq(String.duplicate("0", shared.required_length)))
      end

      context "val contains an invalid character" do
        it "raises an ArgumentError exception" do
          expect( fn-> described_module().numeric_to_metro2("3.4s", shared.required_length, false) end)
          |> to(raise_exception ArgumentError,"field (3.4s) must be numeric")
        end
      end

      context "val is a valid numeric" do
        context "val is bigger than 999,999,999" do
          it "returns 999999999 when is_monetary" do
            test_val = "1000000000.78"
            expect(described_module().numeric_to_metro2(test_val, shared.required_length, true))
            |> to(eq(String.duplicate( "9" ,shared.required_length)))
          end
          it "raises an Argument error" do
            test_val = "1000000000.78"
            expect( fn-> described_module().numeric_to_metro2(test_val, shared.required_length, false) end )
            |> to(raise_exception ArgumentError, "numeric field (#{test_val}) is too long (max #{shared.required_length})")
          end
        end
        context "val is smaller than 999,999,999" do
          it "returns the floored value with leading zeros as fillups" do
            test_val = "34.21"
            result_string = "000000034"
            expect(described_module().numeric_to_metro2(test_val, shared.required_length, false))
            |> to(eq(result_string))
          end
        end
      end
    end
  end
end
