defmodule Metro2.Factory do
  alias Metro2.Records.BaseSegment
  alias Metro2.Records.HeaderSegment
  alias Metro2.Records.TailerSegment

  import Metro2.Fields, only: [put: 3]

  def header_factory do
    %HeaderSegment{}
    |> put(:cycle_number, 15)
    |> put(:equifax_program_identifier, "EFAXID")
    |> put(:transunion_program_identifier, "TRANSUNION")
    |> put(:activity_date, Timex.today )
    |> put(:created_date, Timex.today )
    |> put(:program_date, Timex.today)
    |> put(:reporter_name, "Credit Reporter")
    |> put(:reporter_address, "Reporter Address")
    |> put(:reporter_telephone_number, "1234567890")
  end

  def base_factory do
    %BaseSegment{}
    |> put(:time_stamp, Timex.now())
    |> put(:identification_number, "REPORTERXYZ")
    |> put(:cycle_number, 1)
    |> put(:consumer_account_number, "ABC123")
    |> put(:portfolio_type, "I")
    |> put(:account_type, "01")
    |> put(:date_opened, Timex.today)
    |> put(:highest_credit_or_loan_amount, 25000)
    |> put(:terms_duration, 36)
    |> put(:terms_frequency, "M")
    |> put(:scheduled_monthly_payment_amount, 817.8)
    |> put(:actual_payment_amount, 817.8)
    |> put(:account_status, 11)
    |> put(:payment_history_profile, "00000000000000000BBBBBBB")
    |> put(:current_balance, 1234)
    |> put(:account_information_date, Timex.today)
    |> put(:last_payment_date, Timex.today)
    |> put(:interest_type_indicator, "F")
    |> put(:surname, "Mustermann")
    |> put(:first_name, "Max")
    |> put(:middle_name, "Maria")
    |> put(:social_security_number, "000231743")
    |> put(:date_of_birth, Timex.today)
    |> put(:telephone_number, "1234567890")
    |> put(:ecoa_code, 1)
    |> put(:country_code, "US")
    |> put(:address_1,"742 Evergreen Terrace")
    |> put(:city, "Springfield")
    |> put(:state, "IL")
    |> put(:postal_code, "54321")
    |> put(:address_indicator, "N")
    |> put(:residence_code, "O")
  end
end
