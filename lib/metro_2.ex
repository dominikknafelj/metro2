require IEx;
defmodule Metro2 do
  @portfolio_type %{
      line_of_credit: "C",
      installment: "I",
      mortgage: "M",
      open_account: "O",
      revolving: "R"
    }

    @account_type %{
      unsecured: "01",
      education: "12"
      # TODO: add other account types
    }

    @ecoa_code %{
      individual: "1",
      deceased: "X"
      # TODO: add other ECOA codes
    }

    @special_comment_code %{
      partial_payment_agreement: "AC",
      paid_in_full_less_than_full_balance: "AU",
      loan_modified: "CO",
      forbearance: "CP"
      # TODO: add other special comment codes
    }

    @compliance_condition_code %{
      in_dispute: "XF"
      # TODO: add other compliance condition codes
    }

    @interest_type_indicator %{
      fixed: "F",
      variable: "V"
    }

    @correction_indicator "1"

    @terms_frequency %{
      deferred: "D",
      single_payment: "P",
      weekly: "W",
      biweekly: "B",
      semimonthly: "S",
      monthly: "M",
      bimonthly: "L",
      quarterly: "Q",
      triannually: "T",
      semiannually: "S",
      annually: "Y"
    }

    @account_status %{
      account_transferred: "05",
      current: "11",
      closed: "13",
      paid_in_full_voluntary_surrender: "61",
      paid_in_full_collection_account: "62",
      paid_in_full_repossession: "63",
      paid_in_full_charge_off: "64",
      paid_in_full_foreclosure: "65",
      past_due_30_59: "71",
      past_due_60_89: "78",
      past_due_90_119: "80",
      past_due_120_149: "82",
      past_due_150_179: "83",
      past_due_180_plus: "84",
      govt_insurance_claim_filed: "88",
      deed_received: "89",
      collections: "93",
      foreclosure_completed: "94",
      voluntary_surrender: "95",
      merch_repossessed: "96",
      charge_off: "97",
      delete_account: "DA",
      delete_account_fraud: "DF"
    }

    @payment_history_profile %{
      current: "0",
      past_due_30_59: "1",
      past_due_60_89: "2",
      past_due_90_119: "3",
      past_due_120_149: "4",
      past_due_150_179: "5",
      past_due_180_plus: "6",
      no_history_prior: "B",
      no_history_available: "D",
      zero_balance: "E",
      collection: "G",
      foreclosure_completed: "H",
      voluntary_surrender: "J",
      repossession: "K",
      charge_off: "L"
    }

    @consumer_transaction_type %{
      new_account_or_new_borrower: "1",
      name_change: "2",
      address_change: "3",
      ssn_change: "5",
      name_and_address_change: "6",
      name_and_ssn_change: "8",
      address_and_ssn_change: "9",
      name_address_and_ssn_change: "A"
    }

    @address_indicator %{
      confirmed: "C",
      known: "Y",
      not_confirmed: "N",
      military: "M",
      secondary: "S",
      business: "B",
      non_deliverable: "U",
      data_reporters_default: "D",
      bill_payer_service: "P"
    }

    @residence_code %{
      owns: "O",
      rents: "R"
    }

    @generation_code %{
      junior: "J",
      senior: "S",
      ii: "2",
      iii: "3",
      iv: "4",
      v: "5",
      vi: "6",
      vii: "7",
      viii: "8",
      ix: "9"
    }

    @consumer_information_indicator %{
      petition_ch7: "A",
      petition_ch11: "B",
      petition_ch12: "C",
      petition_ch13: "D",
      discharged_ch7: "E",
      discharged_ch11: "F",
      discharged_ch12: "G",
      discharged_ch13: "H",
      dismissed_ch7: "I",
      dismissed_ch11: "J",
      dismissed_ch12: "K",
      dismissed_ch13: "L",
      withdrawn_ch7: "M",
      withdrawn_ch11: "N",
      withdrawn_ch12: "O",
      withdrawn_ch13: "P",
    }

    def account_status_needs_payment_rating?(account_status) do
      account_status in [@account_status[:account_transferred], @account_status[:closed],
                          @account_status[:paid_in_full_foreclosure], @account_status[:govt_insurance_claim_filed],
                          @account_status[:deed_received], @account_status[:foreclosure_completed],
                          @account_status[:voluntary_surrender]]
    end
end
