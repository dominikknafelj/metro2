defmodule Metro2.Records.BaseSegment do
  @moduledoc """
  This module defines the initial struct for a base segment.
  """
  alias Metro2.Fields.Alphanumeric
  alias Metro2.Fields.Numeric
  alias Metro2.Fields.Monetary
  alias Metro2.Fields.TimeStamp
  alias Metro2.Fields.Date

  defstruct [
    record_descriptor_word: %Numeric{value: Metro2.Base.fixed_length, required_length: 4 },
    processing_indicator: %Alphanumeric{ value: 1, required_length: 1}, # always 1
    time_stamp: %TimeStamp{},
    correction_indicator: %Numeric{required_length: 1},
    identification_number: %Alphanumeric{ required_length: 20},
    cycle_number: %Alphanumeric{ required_length: 2 },
    consumer_account_number: %Alphanumeric{ required_length: 30 },
    portfolio_type: %Alphanumeric{ required_length: 1 },
    account_type: %Alphanumeric{  required_length: 2 },
    date_opened: %Date{},
    credit_limit: %Monetary{},
    highest_credit_or_loan_amount: %Monetary{},
    terms_duration: %Alphanumeric{  required_length: 3 },
    terms_frequency: %Alphanumeric{  required_length: 1 },
    scheduled_monthly_payment_amount: %Monetary{},
    actual_payment_amount: %Monetary{},
    account_status: %Alphanumeric{  required_length: 2 },
    payment_rating: %Alphanumeric{  required_length: 1 },
    payment_history_profile: %Alphanumeric{  required_length: 24 },
    special_comment: %Alphanumeric{  required_length: 2 },
    compliance_condition_code: %Alphanumeric{  required_length: 2 },
    current_balance: %Monetary{},
    amount_past_due: %Monetary{},
    original_charge_off_amount: %Monetary{},
    account_information_date: %Date{},
    first_delinquency_date: %Date{},
    closed_date: %Date{},
    last_payment_date: %Date{},
    interest_type_indicator: %Alphanumeric{  required_length: 1 },
    reserved: %Alphanumeric{  required_length: 16, value: nil }, # blank fill
    consumer_transaction_type: %Alphanumeric{  required_length: 1 },
    surname: %Alphanumeric{  required_length: 25, permitted_chars: Metro2.Base.alphanumeric_plus_dash },
    first_name: %Alphanumeric{  required_length: 20, permitted_chars: Metro2.Base.alphanumeric_plus_dash },
    middle_name: %Alphanumeric{  required_length: 20, permitted_chars: Metro2.Base.alphanumeric_plus_dash },
    generation_code: %Alphanumeric{  required_length: 1 },
    social_security_number: %Numeric{required_length: 9},
    date_of_birth: %Date{},
    telephone_number: %Numeric{required_length: 10},
    ecoa_code: %Alphanumeric{ required_length: 1 },
    consumer_information_indicator: %Alphanumeric{ required_length: 2 },
    country_code: %Alphanumeric{ required_length: 2 },
    address_1: %Alphanumeric{ required_length: 32, permitted_chars: Metro2.Base.alphanumeric_plus_dot_dash_slash },
    address_2: %Alphanumeric{ required_length: 32, permitted_chars: Metro2.Base.alphanumeric_plus_dot_dash_slash },
    city: %Alphanumeric{ required_length: 20, permitted_chars: Metro2.Base.alphanumeric_plus_dot_dash_slash },
    state: %Alphanumeric{ required_length: 2 },
    postal_code: %Alphanumeric{ required_length: 9 },
    address_indicator: %Alphanumeric{ required_length: 1 },
    residence_code: %Alphanumeric{ required_length: 1 },
  ]
  
  @doc false
  def to_metro2(segment), do: Metro2.Segment.to_metro2(segment)
end
