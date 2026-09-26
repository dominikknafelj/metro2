defmodule Metro2.Rules do
  @moduledoc """
  Cross-field consistency rules for base segments.

  **Errors** (`base_errors/1`) are checked by `Metro2.File.validate/1` and fail
  serialization. They are confirmed by the moov-io/metro2 implementation:

    * `account_status` is required
    * statuses 05, 13, 65, 88, 89, 94 and 95 require a `payment_rating`; other statuses
      must leave it blank
    * `payment_history_profile` may only contain payment history codes (or blanks)

  **Warnings** (`base_warnings/1`) are reported by `Metro2.File.warnings/1` and never fail
  serialization. They are likely data problems, but could not be confirmed against the
  CRRG, so a bureau may accept files that violate them:

    * delinquent statuses (71-84, 93, 97) should report a `first_delinquency_date`
    * status 11 (current) should not report an `amount_past_due`
    * past-due statuses (71-84) should report an `amount_past_due`
    * paid or closed statuses (13, 61-65) should report a zero `current_balance`
  """
  alias Metro2.Base
  alias Metro2.Segment

  @delinquent ~w(71 78 80 82 83 84 93 97)
  @past_due ~w(71 78 80 82 83 84)
  @paid_or_closed ~w(13 61 62 63 64 65)
  # blank months (no history reported) are allowed as well
  @history_codes Base.payment_history_profile() |> Map.values() |> Enum.join()
  @history_chars @history_codes <> " "

  @doc """
  Returns `[{field, message}]` for every error rule the base segment violates.
  """
  def base_errors(base) do
    status = Segment.value(base, :account_status)

    [
      {:account_status, "is required", blank?(base, :account_status)},
      {:payment_rating, "is required for account status #{status}",
       Base.account_status_needs_payment_rating?(status) and
         Segment.value(base, :payment_rating) == nil},
      {:payment_rating, "must be blank for account status #{status}",
       status != nil and not Base.account_status_needs_payment_rating?(status) and
         Segment.value(base, :payment_rating) != nil},
      {:payment_history_profile, "may only contain the codes #{@history_codes}",
       invalid_history?(Segment.value(base, :payment_history_profile))}
    ]
    |> violations()
  end

  @doc """
  Returns `[{field, message}]` for every warning rule the base segment violates.
  """
  def base_warnings(base) do
    status = Segment.value(base, :account_status)

    [
      {:first_delinquency_date, "is expected for account status #{status}",
       status in @delinquent and not Segment.present?(base, :first_delinquency_date)},
      {:amount_past_due, "is expected to be 0 for account status 11 (current)",
       status == "11" and Segment.present?(base, :amount_past_due)},
      {:amount_past_due, "is expected to be greater than 0 for account status #{status}",
       status in @past_due and not Segment.present?(base, :amount_past_due)},
      {:current_balance, "is expected to be 0 for account status #{status}",
       status in @paid_or_closed and Segment.present?(base, :current_balance)}
    ]
    |> violations()
  end

  defp violations(checks) do
    for {field, message, true} <- checks, do: {field, message}
  end

  # blank, as opposed to invalid (which is reported as a field error)
  defp blank?(segment, field) do
    case Metro2.Fields.format(Map.fetch!(segment, field)) do
      {:ok, formatted} -> String.trim(formatted) == ""
      {:error, _} -> false
    end
  end

  defp invalid_history?(nil), do: false

  defp invalid_history?(profile) do
    profile |> String.graphemes() |> Enum.any?(&(not String.contains?(@history_chars, &1)))
  end
end
