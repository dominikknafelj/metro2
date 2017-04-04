require IEx;
defmodule Metro2 do
  @portfolio_type %{
      line_of_credit: "C",
      installment:    "I",
      mortgage:       "M",
      open_account:   "O",
      revolving:      "R"
    }

  @account_type %{
    unsecured: "01",
    education: "12"
    # TODO: add other account types
  }

  @ecoa_code %{
    individual: "1",
    deceased:   "X"
    # TODO: add other ECOA codes
  }

  @special_comment_code %{
    partial_payment_agreement:            "AC",
    paid_in_full_less_than_full_balance:  "AU",
    loan_modified:                        "CO",
    forbearance:                          "CP"
    # TODO: add other special comment codes
  }

  @compliance_condition_code %{
    in_dispute: "XF"
    # TODO: add other compliance condition codes
  }

  @interest_type_indicator %{
    fixed:    "F",
    variable: "V"
  }

  @correction_indicator "1"

  @terms_frequency %{
    deferred:       "D",
    single_payment: "P",
    weekly:         "W",
    biweekly:       "B",
    semimonthly:    "S",
    monthly:        "M",
    bimonthly:      "L",
    quarterly:      "Q",
    triannually:    "T",
    semiannually:   "S",
    annually:       "Y"
  }

  @account_status %{
    account_transferred:              "05",
    current:                          "11",
    closed:                           "13",
    paid_in_full_voluntary_surrender: "61",
    paid_in_full_collection_account:  "62",
    paid_in_full_repossession:        "63",
    paid_in_full_charge_off:          "64",
    paid_in_full_foreclosure:         "65",
    past_due_30_59:                   "71",
    past_due_60_89:                   "78",
    past_due_90_119:                  "80",
    past_due_120_149:                 "82",
    past_due_150_179:                 "83",
    past_due_180_plus:                "84",
    govt_insurance_claim_filed:       "88",
    deed_received:                    "89",
    collections:                      "93",
    foreclosure_completed:            "94",
    voluntary_surrender:              "95",
    merch_repossessed:                "96",
    charge_off:                       "97",
    delete_account:                   "DA",
    delete_account_fraud:             "DF"
  }

  @payment_history_profile %{
    current:                "0",
    past_due_30_59:         "1",
    past_due_60_89:         "2",
    past_due_90_119:        "3",
    past_due_120_149:       "4",
    past_due_150_179:       "5",
    past_due_180_plus:      "6",
    no_history_prior:       "B",
    no_history_available:   "D",
    zero_balance:           "E",
    collection:             "G",
    foreclosure_completed:  "H",
    voluntary_surrender:    "J",
    repossession:           "K",
    charge_off:             "L"
  }

  @consumer_transaction_type %{
    new_account_or_new_borrower:  "1",
    name_change:                  "2",
    address_change:               "3",
    ssn_change:                   "5",
    name_and_address_change:      "6",
    name_and_ssn_change:          "8",
    address_and_ssn_change:       "9",
    name_address_and_ssn_change:  "A"
  }

  @address_indicator %{
    confirmed:              "C",
    known:                  "Y",
    not_confirmed:          "N",
    military:               "M",
    secondary:              "S",
    business:               "B",
    non_deliverable:        "U",
    data_reporters_default: "D",
    bill_payer_service:     "P"
  }

  @residence_code %{
    owns:     "O",
    rents:    "R"
  }

  @generation_code %{
    junior:   "J",
    senior:   "S",
    ii:       "2",
    iii:      "3",
    iv:       "4",
    v:        "5",
    vi:       "6",
    vii:      "7",
    viii:     "8",
    ix:       "9"
  }

  @consumer_information_indicator %{
    petition_ch7:     "A",
    petition_ch11:    "B",
    petition_ch12:    "C",
    petition_ch13:    "D",
    discharged_ch7:   "E",
    discharged_ch11:  "F",
    discharged_ch12:  "G",
    discharged_ch13:  "H",
    dismissed_ch7:    "I",
    dismissed_ch11:   "J",
    dismissed_ch12:   "K",
    dismissed_ch13:   "L",
    withdrawn_ch7:    "M",
    withdrawn_ch11:   "N",
    withdrawn_ch12:   "O",
    withdrawn_ch13:   "P",
  }

  @alphanumeric                      ~r/\A([[:alnum:]]|\s)+\z/
  @alphanumeric_plus_dash            ~r/\A([[:alnum:]]|\s|\-)+\z/
  @alphanumeric_plus_dot_dash_slash  ~r/\A([[:alnum:]]|\s|\-|\.|\\|\/)+\z/
  @numeric                           ~r/\A\d+\.?\d*\z/
  @integer                           ~r/\d+\z/
  @fixed_length 426
  @decimal_seperator "."

  def portfolio_type, do: @portfolio_type
  def account_type, do: @account_type
  def ecoa_code, do: @ecoa_code
  def special_comment_code, do: @special_comment_code
  def compliance_condition_code, do: @compliance_condition_code
  def interest_type_indicator, do: @interest_type_indicator
  def correction_indicator, do: @correction_indicator
  def terms_frequency, do: @terms_frequency
  def account_status, do: @account_status
  def payment_history_profile, do: @payment_history_profile
  def consumer_transaction_type, do: @consumer_transaction_type
  def address_indicator, do: @address_indicator
  def residence_code, do: @residence_code
  def generation_code, do: @generation_code
  def consumer_information_indicator, do: @consumer_information_indicator
  def alphanumeric, do: @alphanumeric
  def alphanumeric_plus_dash, do: @alphanumeric_plus_dash
  def alphanumeric_plus_dot_dash_slash, do: @alphanumeric_plus_dot_dash_slash
  def numeric, do: @numeric
  def integer, do: @integer
  def fixed_length, do: @fixed_length

  def account_status_needs_payment_rating?(account_status) do
      account_status in [@account_status[:account_transferred], @account_status[:closed],
                          @account_status[:paid_in_full_foreclosure], @account_status[:govt_insurance_claim_filed],
                          @account_status[:deed_received], @account_status[:foreclosure_completed],
                          @account_status[:voluntary_surrender]]
  end

  def alphanumeric_to_metro2(nil = val, required_length, _, _ ) do
    String.duplicate(" ", required_length)
  end

  def alphanumeric_to_metro2("" = val, required_length,  _, _ ) do
    String.duplicate(" ", required_length)
  end

  def alphanumeric_to_metro2(val, required_length, permitted_chars, name) do
    unless Regex.match?(permitted_chars, val) do
      raise ArgumentError, message: "Content (#{val}) contains invalid characters in field '#{name}'"
    end

    if String.length(val) > required_length do
      String.slice(val, 0..(required_length-1))
    else
      val <> String.duplicate(" ", required_length - String.length(val))
    end
  end

  def strip_fractions(val) do
    cond do
      Regex.match?(numeric, val) -> val
                                    |> String.split(".", parts: 2)
                                    |> List.first
      true                       -> raise ArgumentError, message: "field (#{val}) must be numeric"
    end
  end


  def numeric_to_metro2(nil = val, required_length, _) do
    String.duplicate("0", required_length)
  end

  def numeric_to_metro2("" = val, required_length, _) do
    String.duplicate("0", required_length)
  end


  def numeric_to_metro2(val, required_length, is_monetary) do
      # Right justified and zero-filled
      number = strip_fractions(val)
    cond do
      # when we have a monetary value and we exceed the billion we limit to 999,999,999
      is_monetary && String.to_integer(number) >= 1000000000  -> String.duplicate("9", required_length)
      # normal case, we return the value with leading 0 as fillup
      String.length(number) <= required_length              -> ("0" |> String.duplicate(required_length - String.length(number))) <> number
      # when we don't have a monetary value and we exceed the required_length
      true                                                  -> raise ArgumentError, message: "numeric field (#{val}) is too long (max #{required_length})"
    end
  end
end
