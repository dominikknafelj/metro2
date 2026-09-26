defmodule Metro2.Base do
  @moduledoc """
  This module contains all the elementar parts of the metro2 generation, like:
    * Maps which translate humanized states into metro2 codes
    * The sets of valid codes for fields with a closed code list
    * Regular expressions for valid numerics and alphanumerics
    * Functions which convert values into a metro2 compatible format
  """
  @portfolio_type %{
    line_of_credit: "C",
    installment: "I",
    mortgage: "M",
    open_account: "O",
    revolving: "R",
    lease: "L"
  }

  # Partial humanized map; the complete code list is in @valid_codes.
  @account_type %{
    unsecured: "01",
    education: "12"
  }

  @ecoa_code %{
    individual: "1",
    joint_contractual_liability: "2",
    authorized_user: "3",
    co_maker: "5",
    maker: "7",
    association_terminated: "T",
    business_commercial: "W",
    deceased: "X",
    delete_consumer: "Z"
  }

  # Partial humanized map; the complete code list is in @valid_codes.
  @special_comment_code %{
    partial_payment_agreement: "AC",
    paid_in_full_less_than_full_balance: "AU",
    loan_modified: "CO",
    forbearance: "CP"
  }

  # Partial humanized map; the complete code list is in @valid_codes.
  @compliance_condition_code %{
    in_dispute: "XF"
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
    semimonthly: "E",
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

  @payment_rating %{
    current: "0",
    past_due_30_59: "1",
    past_due_60_89: "2",
    past_due_90_119: "3",
    past_due_120_149: "4",
    past_due_150_179: "5",
    past_due_180_plus: "6",
    collection: "G",
    charge_off: "L"
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
    charge_off: "L",
    too_new_to_rate: "Z"
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

  # Partial humanized map; consumer_information_indicator accepts any 1-2 character code.
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
    withdrawn_ch13: "P"
  }

  @purchased_from_sold_to_indicator %{
    purchased_from: "1",
    sold_to: "2",
    remove: "9"
  }

  @change_indicator %{
    account_number: "1",
    identification_number: "2",
    both: "3"
  }

  @specialized_payment_indicator %{
    balloon_payment: "01",
    deferred_payment: "02"
  }

  @agency_identifier %{
    not_applicable: "00",
    fannie_mae: "01",
    freddie_mac: "02"
  }

  @creditor_classification %{
    retail: "01",
    medical: "02",
    oil: "03",
    government: "04",
    personal: "05",
    insurance: "06",
    educational: "07",
    banking: "08",
    rental: "09",
    utilities: "10",
    cable: "11",
    financial: "12",
    credit: "13",
    automotive: "14",
    guarantee: "15"
  }

  @code_tables %{
    portfolio_type: @portfolio_type,
    account_type: @account_type,
    ecoa_code: @ecoa_code,
    special_comment: @special_comment_code,
    compliance_condition_code: @compliance_condition_code,
    interest_type_indicator: @interest_type_indicator,
    terms_frequency: @terms_frequency,
    account_status: @account_status,
    payment_rating: @payment_rating,
    consumer_transaction_type: @consumer_transaction_type,
    address_indicator: @address_indicator,
    residence_code: @residence_code,
    generation_code: @generation_code,
    consumer_information_indicator: @consumer_information_indicator,
    purchased_from_sold_to_indicator: @purchased_from_sold_to_indicator,
    change_indicator: @change_indicator,
    specialized_payment_indicator: @specialized_payment_indicator,
    agency_identifier: @agency_identifier,
    creditor_classification: @creditor_classification
  }

  # Fields whose values must come from a closed list. Tables missing here are open:
  # any value made of permitted characters is accepted.
  # Account type and special comment lists match moov-io/metro2 (pkg/lib/constants.go).
  @valid_codes %{
    portfolio_type: Map.values(@portfolio_type),
    account_type: ~w(00 01 02 03 04 05 06 07 08 0A 0C 0F 0G 10 11 12 13 15 17 18 19 20 25 26 29 2A
                     2C 37 3A 43 47 48 4D 50 5A 5B 65 66 67 68 69 6A 6B 6D 70 71 72 73 74 75 77 7A
                     7B 89 8A 8B 90 91 92 93 95 9A 9B),
    special_comment: ~w(B C H I M O S V AB AC AH AI AM AN AO AP AS AT AU AV AW AX AZ BA BB BC BD BE
                        BF BG BH BI BJ BK BL BN BO BP BS BT CH CI CJ CK CL CM CN CO CP CS DE),
    purchased_from_sold_to_indicator: Map.values(@purchased_from_sold_to_indicator),
    change_indicator: Map.values(@change_indicator),
    specialized_payment_indicator: Map.values(@specialized_payment_indicator),
    agency_identifier: Map.values(@agency_identifier),
    creditor_classification: Map.values(@creditor_classification),
    ecoa_code: Map.values(@ecoa_code),
    compliance_condition_code: ~w(XA XB XC XD XE XF XG XH XJ XR),
    interest_type_indicator: Map.values(@interest_type_indicator),
    terms_frequency: Map.values(@terms_frequency),
    account_status: Map.values(@account_status),
    payment_rating: Map.values(@payment_rating),
    consumer_transaction_type: Map.values(@consumer_transaction_type),
    address_indicator: Map.values(@address_indicator),
    residence_code: Map.values(@residence_code),
    generation_code: Map.values(@generation_code)
  }

  @alphanumeric ~r/\A([[:alnum:]]| )+\z/
  @alphanumeric_plus_dash ~r/\A([[:alnum:]]| |\-)+\z/
  @alphanumeric_plus_dot_dash_slash ~r/\A([[:alnum:]]| |\-|\.|\\|\/)+\z/
  @numeric ~r/\A\d+\.?\d*\z/
  @integer ~r/\d+\z/
  @fixed_length 426
  @decimal_separator "."
  @version_string "01"

  def portfolio_type, do: @portfolio_type
  def account_type, do: @account_type
  def ecoa_code, do: @ecoa_code
  def special_comment_code, do: @special_comment_code
  def compliance_condition_code, do: @compliance_condition_code
  def interest_type_indicator, do: @interest_type_indicator
  def correction_indicator, do: @correction_indicator
  def terms_frequency, do: @terms_frequency
  def account_status, do: @account_status
  def payment_rating, do: @payment_rating
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
  def version_string, do: @version_string
  def decimal_separator, do: @decimal_separator

  @doc """
  Returns the humanized-atom to code map for a code field, e.g. `code_table(:account_status)`.
  """
  def code_table(name), do: Map.fetch!(@code_tables, name)

  @doc """
  Returns the list of valid codes for a field with a closed code list, or `nil` when any
  code made of permitted characters is accepted.
  """
  def valid_codes(name), do: Map.get(@valid_codes, name)

  @doc """
    function to check if a certain account status needs a payment rating
  """
  def account_status_needs_payment_rating?(account_status) do
    account_status in [
      @account_status[:account_transferred],
      @account_status[:closed],
      @account_status[:paid_in_full_foreclosure],
      @account_status[:govt_insurance_claim_filed],
      @account_status[:deed_received],
      @account_status[:foreclosure_completed],
      @account_status[:voluntary_surrender]
    ]
  end

  # converts val into an alphanumeric metro2 format with the required length, raising on
  # invalid content. See format_alphanumeric/3.
  @doc false
  def alphanumeric_to_metro2(val, required_length, permitted_chars) do
    case format_alphanumeric(val, required_length, permitted_chars) do
      {:ok, formatted} -> formatted
      {:error, message} -> raise ArgumentError, message: message
    end
  end

  # converts val into an alphanumeric metro2 format with the required length.
  # nil and "" become blanks, too long values are cut, short values are padded with trailing
  # spaces. Returns {:error, message} when val contains characters outside permitted_chars.
  @doc false
  def format_alphanumeric(nil, required_length, _), do: {:ok, blanks(required_length)}
  def format_alphanumeric("", required_length, _), do: {:ok, blanks(required_length)}

  def format_alphanumeric(val, required_length, permitted_chars) when is_integer(val) do
    val |> Integer.to_string() |> format_alphanumeric(required_length, permitted_chars)
  end

  def format_alphanumeric(val, required_length, permitted_chars) when is_float(val) do
    val |> Float.to_string() |> format_alphanumeric(required_length, permitted_chars)
  end

  def format_alphanumeric(val, required_length, permitted_chars) when is_binary(val) do
    if Regex.match?(permitted_chars, val) do
      {:ok, val |> String.slice(0, required_length) |> String.pad_trailing(required_length)}
    else
      {:error, "Content (#{val}) contains invalid characters"}
    end
  end

  def format_alphanumeric(val, _, _), do: {:error, "Content (#{inspect(val)}) is not a string"}

  # converts a numeric to a metro2 field, raising on invalid content. See format_numeric/3.
  @doc false
  def numeric_to_metro2(val, required_length, is_monetary) do
    case format_numeric(val, required_length, is_monetary) do
      {:ok, formatted} -> formatted
      {:error, message} -> raise ArgumentError, message: message
    end
  end

  # converts a numeric to a metro2 field.
  # nil and "" become zeros, floats are floored.
  # monetary values are limited to 999,999,999 and negative monetary values (e.g. credit
  # balances) are reported as 0.
  # non monetary fields return an error for being too long or negative.
  @doc false
  def format_numeric(nil, required_length, _), do: {:ok, zeros(required_length)}
  def format_numeric("", required_length, _), do: {:ok, zeros(required_length)}

  def format_numeric(val, required_length, is_monetary) do
    case normalize_numeric(val) do
      {:ok, x} when x < 0 and is_monetary ->
        {:ok, zeros(required_length)}

      {:ok, x} when x < 0 ->
        {:error, "numeric field (#{val}) must not be negative"}

      # when we have a monetary value and we exceed the billion we limit to 999,999,999
      {:ok, x} when x >= 1_000_000_000 and is_monetary ->
        {:ok, String.duplicate("9", required_length)}

      {:ok, x} ->
        digits = Integer.to_string(x)

        if String.length(digits) <= required_length do
          {:ok, String.pad_leading(digits, required_length, "0")}
        else
          {:error, "numeric field (#{val}) is too long (max #{required_length})"}
        end

      error ->
        error
    end
  end

  defp normalize_numeric(val) when is_integer(val), do: {:ok, val}
  defp normalize_numeric(val) when is_float(val), do: {:ok, val |> Float.floor() |> round()}

  defp normalize_numeric(val) when is_binary(val) do
    case Float.parse(val) do
      {x, ""} -> normalize_numeric(x)
      _ -> {:error, "value #{val} is not parseable to Float (strict)"}
    end
  end

  defp normalize_numeric(val), do: {:error, "value #{inspect(val)} is not numeric"}

  defp blanks(length), do: String.duplicate(" ", length)
  defp zeros(length), do: String.duplicate("0", length)
end
