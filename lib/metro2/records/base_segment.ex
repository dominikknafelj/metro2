defmodule Metro2.Records.BaseSegment do
  alias Metro2.Fields.Alphanumeric
  alias Metro2.Fields.Numeric
  alias Metro2.Fields.Monetary
  alias Metro2.Fields.TimeStamp
  alias Metro2.Fields.Date

  defstruct [
    record_descriptor_word: %Numeric{value: 4, required_length: Metro2.Base.fixed_length },
    processing_indicator: %Alphanumeric{name: "processing_indicator", value: 1, required_length: 1}, # always 1
    time_stamp: %TimeStamp{},
    correction_indicator: %Numeric{required_length: 1},
    identification_number: %Alphanumeric{ name: "identification_number", required_length: 20},
    cycle_number: %Alphanumeric{ name: "cycle_number", required_length: 2 },
    consumer_account_number: %Alphanumeric{ name: "consumer_account_number", required_length: 30 },
    portfolio_type: %Alphanumeric{ name: "portfolio_type", required_length: 1 },
    account_type: %Alphanumeric{ name: "account_type", required_length: 2 },
    date_opened: %Date{},
    credit_limit: %Monetary{},
    highest_credit_or_loan_amount: %Monetary{},
    terms_duration: %Alphanumeric{ name: "terms_duration", required_length: 3 },
    terms_frequency: %Alphanumeric{ name: "terms_frequency", required_length: 1 },
    scheduled_monthly_payment_amount: %Monetary{},
    actual_payment_amount: %Monetary{},
    account_status: %Alphanumeric{ name: "account_status", required_length: 2 },
    payment_rating: %Alphanumeric{ name: "payment_rating", required_length: 1 },
    payment_history_profile: %Alphanumeric{ name: "payment_history_profile", required_length: 24 },
    special_comment: %Alphanumeric{ name: "special_comment", required_length: 2 },
    compliance_condition_code: %Alphanumeric{ name: "compliance_condition_code", required_length: 2 },
    current_balance: %Monetary{},
    amount_past_due: %Monetary{},
    original_charge_off_amount: %Monetary{},
    account_information_date: %Date{},
    first_delinquency_date: %Date{},
    closed_date: %Date{},
    last_payment_date: %Date{},
    interest_type_indicator: %Alphanumeric{ name: "interest_type_indicator", required_length: 1 },
    reserved: %Alphanumeric{ name: "reserved", required_length: 16, value: nil }, # blank fill
    consumer_transaction_type: %Alphanumeric{ name: "consumer_transaction_type", required_length: 1 },
    surname: %Alphanumeric{ name: "surname", required_length: 25, permitted_chars: Metro2.Base.alphanumeric_plus_dash },
    first_name: %Alphanumeric{ name: "first_name", required_length: 20, permitted_chars: Metro2.Base.alphanumeric_plus_dash },
    middle_name: %Alphanumeric{ name: "middle_name", required_length: 20, permitted_chars: Metro2.Base.alphanumeric_plus_dash },
    generation_code: %Alphanumeric{ name: "generation_code", required_length: 1 },
    social_security_number: %Numeric{required_length: 9},
    date_of_birth: %Date{},
    telephone_number: %Numeric{required_length: 10},
    ecoa_code: %Alphanumeric{ name: "ecoa_code", required_length: 1 },
    consumer_information_indicator: %Alphanumeric{ name: "consumer_information_indicator", required_length: 2 },
    country_code: %Alphanumeric{ name: "country_code", required_length: 2 },
    address_1: %Alphanumeric{ name: "address_1", required_length: 32, permitted_chars: Metro2.Base.alphanumeric_plus_dot_dash_slash },
    address_2: %Alphanumeric{ name: "address_2", required_length: 32, permitted_chars: Metro2.Base.alphanumeric_plus_dot_dash_slash },
    city: %Alphanumeric{ name: "city", required_length: 20, permitted_chars: Metro2.Base.alphanumeric_plus_dot_dash_slash },
    state: %Alphanumeric{ name: "state", required_length: 2 },
    postal_code: %Alphanumeric{ name: "postal_code", required_length: 9 },
    address_indicator: %Alphanumeric{ name: "address_indicator", required_length: 1 },
    residence_code: %Alphanumeric{ name: "residence_code", required_length: 1 },
  ]
end
