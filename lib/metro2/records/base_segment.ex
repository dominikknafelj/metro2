defmodule Metro2.Records.BaseSegment do
  @moduledoc """
  This module defines the initial struct for a base segment.

  Code fields (e.g. `:account_status`, `:portfolio_type`, `:ecoa_code`) accept either the
  METRO 2 code (`"11"`) or the humanized atom from `Metro2.Base` (`:current`).

  Appended segments (J1, J2, K1-K4, L1, N1) are added with `add_segment/2` and are written
  after the 426 fixed characters of the base segment, in that order. The record descriptor
  word is set to the resulting total record length.
  """
  alias Metro2.Fields.Alphanumeric
  alias Metro2.Fields.Date
  alias Metro2.Fields.Monetary
  alias Metro2.Fields.Numeric
  alias Metro2.Fields.TimeStamp
  alias Metro2.Records

  # Declaration order is the METRO 2 record layout order; serialization relies on it.
  @fields [
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
    :residence_code
  ]

  # Appended segments in the order they are written after the fixed base segment.
  # J1 and J2 can occur multiple times, the others at most once.
  @appendage_keys [:j1, :j2, :k1, :k2, :k3, :k4, :l1, :n1]
  @repeatable [:j1, :j2]

  defstruct @fields ++ [j1: [], j2: [], k1: nil, k2: nil, k3: nil, k4: nil, l1: nil, n1: nil]

  @doc false
  def fields, do: @fields

  @doc """
  Creates a new BaseSegment with properly initialized fields
  """
  def new do
    %__MODULE__{
      record_descriptor_word: Numeric.new(4, Metro2.Base.fixed_length()),
      # always 1
      processing_indicator: Alphanumeric.new(1, 1),
      time_stamp: TimeStamp.new(),
      correction_indicator: Numeric.new(1),
      identification_number: Alphanumeric.new(20),
      cycle_number: Alphanumeric.new(2),
      consumer_account_number: Alphanumeric.new(30),
      portfolio_type: Alphanumeric.new_code(1, :portfolio_type),
      account_type: Alphanumeric.new_code(2, :account_type),
      date_opened: Date.new(),
      credit_limit: Monetary.new(),
      highest_credit_or_loan_amount: Monetary.new(),
      terms_duration: Alphanumeric.new(3),
      terms_frequency: Alphanumeric.new_code(1, :terms_frequency),
      scheduled_monthly_payment_amount: Monetary.new(),
      actual_payment_amount: Monetary.new(),
      account_status: Alphanumeric.new_code(2, :account_status),
      payment_rating: Alphanumeric.new_code(1, :payment_rating),
      payment_history_profile: Alphanumeric.new(24),
      special_comment: Alphanumeric.new_code(2, :special_comment),
      compliance_condition_code: Alphanumeric.new_code(2, :compliance_condition_code),
      current_balance: Monetary.new(),
      amount_past_due: Monetary.new(),
      original_charge_off_amount: Monetary.new(),
      account_information_date: Date.new(),
      first_delinquency_date: Date.new(),
      closed_date: Date.new(),
      last_payment_date: Date.new(),
      interest_type_indicator: Alphanumeric.new_code(1, :interest_type_indicator),
      # blank fill
      reserved: Alphanumeric.new(16, nil),
      consumer_transaction_type: Alphanumeric.new_code(1, :consumer_transaction_type),
      surname: Alphanumeric.new_with_dash(25),
      first_name: Alphanumeric.new_with_dash(20),
      middle_name: Alphanumeric.new_with_dash(20),
      generation_code: Alphanumeric.new_code(1, :generation_code),
      social_security_number: Numeric.new_identifier(9),
      date_of_birth: Date.new(),
      telephone_number: Numeric.new_identifier(10),
      ecoa_code: Alphanumeric.new_code(1, :ecoa_code),
      consumer_information_indicator: Alphanumeric.new_code(2, :consumer_information_indicator),
      country_code: Alphanumeric.new(2),
      address_1: Alphanumeric.new_with_dot_dash_slash(32),
      address_2: Alphanumeric.new_with_dot_dash_slash(32),
      city: Alphanumeric.new_with_dot_dash_slash(20),
      state: Alphanumeric.new(2),
      postal_code: Alphanumeric.new(9, nil, strip: ~r/-/),
      address_indicator: Alphanumeric.new_code(1, :address_indicator),
      residence_code: Alphanumeric.new_code(1, :residence_code)
    }
  end

  @doc """
  Appends a J1, J2, K1, K2, K3, K4, L1 or N1 segment to the base segment.
  J1 and J2 segments accumulate; any other segment replaces an existing one of the same type.
  """
  def add_segment(%__MODULE__{} = base, %{__struct__: module} = segment) do
    key = module.segment_key()

    if key in @repeatable do
      Map.update!(base, key, &(&1 ++ [segment]))
    else
      Map.put(base, key, segment)
    end
  end

  @doc """
  Returns the appended segments in the order they are written.
  """
  def appendages(%__MODULE__{} = base) do
    Enum.flat_map(@appendage_keys, fn key -> base |> Map.fetch!(key) |> List.wrap() end)
  end

  @doc """
  Total record length: 426 fixed characters plus the length of all appended segments.
  """
  def record_length(%__MODULE__{} = base) do
    base
    |> appendages()
    |> Enum.reduce(Metro2.Base.fixed_length(), &(&1.__struct__.record_length() + &2))
  end

  @doc false
  def appendage_module(segment_id) do
    Map.get(
      %{
        "J1" => Records.J1Segment,
        "J2" => Records.J2Segment,
        "K1" => Records.K1Segment,
        "K2" => Records.K2Segment,
        "K3" => Records.K3Segment,
        "K4" => Records.K4Segment,
        "L1" => Records.L1Segment,
        "N1" => Records.N1Segment
      },
      segment_id
    )
  end

  @doc false
  def to_metro2(segment), do: Metro2.Segment.to_metro2(segment)
end
