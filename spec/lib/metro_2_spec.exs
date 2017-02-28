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
  end
end
