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
    :record_descriptor_word,
    :processing_indicator,
    :time_stamp,
    :correction_indicator,
    :identification_number,
    :cycle_number,
    :consumer_account_number,
    :portfolio_type,
    :account_type,
    :date_opened,
    :credit_limit,
    :highest_credit_or_loan_amount,
    :terms_duration,
    :terms_frequency,
    :scheduled_monthly_payment_amount,
    :actual_payment_amount,
    :account_status,
    :payment_rating,
    :payment_history_profile,
    :special_comment,
    :compliance_condition_code,
    :current_balance,
    :amount_past_due,
    :original_charge_off_amount,
    :account_information_date,
    :first_delinquency_date,
    :closed_date,
    :last_payment_date,
    :interest_type_indicator,
    :reserved,
    :consumer_transaction_type,
    :surname,
    :first_name,
    :middle_name,
    :generation_code,
    :social_security_number,
    :date_of_birth,
    :telephone_number,
    :ecoa_code,
    :consumer_information_indicator,
    :country_code,
    :address_1,
    :address_2,
    :city,
    :state,
    :postal_code,
    :address_indicator,
    :residence_code,
  ]

  @doc """
  Creates a new BaseSegment with properly initialized fields
  """
  def new do
    %__MODULE__{
      record_descriptor_word: Numeric.new(4, Metro2.Base.fixed_length()),
      processing_indicator: Alphanumeric.new(1, 1), # always 1
      time_stamp: TimeStamp.new(),
      correction_indicator: Numeric.new(1),
      identification_number: Alphanumeric.new(20),
      cycle_number: Alphanumeric.new(2),
      consumer_account_number: Alphanumeric.new(30),
      portfolio_type: Alphanumeric.new(1),
      account_type: Alphanumeric.new(2),
      date_opened: Date.new(),
      credit_limit: Monetary.new(),
      highest_credit_or_loan_amount: Monetary.new(),
      terms_duration: Alphanumeric.new(3),
      terms_frequency: Alphanumeric.new(1),
      scheduled_monthly_payment_amount: Monetary.new(),
      actual_payment_amount: Monetary.new(),
      account_status: Alphanumeric.new(2),
      payment_rating: Alphanumeric.new(1),
      payment_history_profile: Alphanumeric.new(24),
      special_comment: Alphanumeric.new(2),
      compliance_condition_code: Alphanumeric.new(2),
      current_balance: Monetary.new(),
      amount_past_due: Monetary.new(),
      original_charge_off_amount: Monetary.new(),
      account_information_date: Date.new(),
      first_delinquency_date: Date.new(),
      closed_date: Date.new(),
      last_payment_date: Date.new(),
      interest_type_indicator: Alphanumeric.new(1),
      reserved: Alphanumeric.new(16, nil), # blank fill
      consumer_transaction_type: Alphanumeric.new(1),
      surname: Alphanumeric.new_with_dash(25),
      first_name: Alphanumeric.new_with_dash(20),
      middle_name: Alphanumeric.new_with_dash(20),
      generation_code: Alphanumeric.new(1),
      social_security_number: Numeric.new(9),
      date_of_birth: Date.new(),
      telephone_number: Numeric.new(10),
      ecoa_code: Alphanumeric.new(1),
      consumer_information_indicator: Alphanumeric.new(2),
      country_code: Alphanumeric.new(2),
      address_1: Alphanumeric.new_with_dot_dash_slash(32),
      address_2: Alphanumeric.new_with_dot_dash_slash(32),
      city: Alphanumeric.new_with_dot_dash_slash(20),
      state: Alphanumeric.new(2),
      postal_code: Alphanumeric.new(9),
      address_indicator: Alphanumeric.new(1),
      residence_code: Alphanumeric.new(1),
    }
  end
  
  @doc false
  def to_metro2(segment), do: Metro2.Segment.to_metro2(segment)
end
