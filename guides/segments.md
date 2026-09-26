# METRO 2® Segments

A METRO 2® file is a sequence of fixed-length records, one per line:

```
HEADER   one per file        who is reporting, for which bureaus, as of when
BASE     one per account     the account and its primary consumer
  J1/J2/K1-K4/L1/N1          optional segments appended to a base record
TRAILER  one per file        totals the bureaus use to check the file is complete
```

Every record starts with a 4-digit **record descriptor word** (RDW): its total length.
Header, tailer and a plain base record are 426 characters. A base record with appended
segments is longer, and its RDW says by how much. The library sets the RDW for you.

This library implements the 426-character (character) format. The authoritative field
definitions are in the Credit Reporting Resource Guide (CRRG®) published by the CDIA;
check field meanings and code values there before reporting to a bureau.

## Header — `Metro2.Records.HeaderSegment`

Identifies the data furnisher and the reporting period. One per file, always first.

| Field | Purpose |
|---|---|
| `cycle_number` | Reporting cycle identifier if you report in cycles, otherwise blank |
| `innovis_program_identifier`, `equifax_program_identifier`, `experian_program_identifier`, `transunion_program_identifier` | The identifiers each bureau assigned to you; fill the ones you report to |
| `activity_date` | Date of the account activity being reported. Defaults to today |
| `created_date` | Date the file was created. Defaults to today |
| `program_date`, `program_revision_date` | Dates your reporting program was first reported / last revised |
| `reporter_name`, `reporter_address`, `reporter_telephone_number` | Your organization's contact details |
| `software_vendor_name`, `software_version_number` | Prefilled (`Metro2Elix`, `01`) |

## Base — `Metro2.Records.BaseSegment`

One per reportable account: the account's terms, balances and status, plus the primary
consumer's identity and address. Most reporting work is filling base segments.

**Account identification**

| Field | Purpose |
|---|---|
| `identification_number` | Your identifier as a furnisher (per bureau) |
| `consumer_account_number` | The account number. Changing it requires an L1 segment |
| `portfolio_type` | `:line_of_credit` (C), `:installment` (I), `:mortgage` (M), `:open_account` (O), `:revolving` (R) |
| `account_type` | 2-character account type code (e.g. `"01"` unsecured, `"12"` education) |
| `date_opened`, `closed_date`, `last_payment_date`, `account_information_date` | Key account dates |

**Terms and amounts** (whole dollars; cents are dropped, negatives report as 0)

| Field | Purpose |
|---|---|
| `credit_limit`, `highest_credit_or_loan_amount` | Limit for revolving/credit lines; original loan amount for installments |
| `terms_duration`, `terms_frequency` | Number of payments and how often (`:monthly`, `:biweekly`, ...) |
| `scheduled_monthly_payment_amount`, `actual_payment_amount` | What was due and what was paid this period |
| `current_balance`, `amount_past_due`, `original_charge_off_amount` | Balances as of the activity date |
| `interest_type_indicator` | `:fixed` (F) or `:variable` (V) |

**Status and history** — the heart of the report

| Field | Purpose |
|---|---|
| `account_status` | Current state of the account; see the table below. Required |
| `payment_rating` | How the account stood when it was closed/transferred; required for statuses 05, 13, 65, 88, 89, 94, 95 |
| `payment_history_profile` | 24 characters, most recent month first, one code per month (`0` current, `1`–`6` 30–180+ days late, `B` no history before, `D` no history available, `E` zero balance, ...) |
| `first_delinquency_date` | FCRA date of first delinquency; required for delinquent statuses (71–84, 93, 97) |
| `special_comment` | Special comment code (e.g. `"AC"` partial payment agreement) |
| `compliance_condition_code` | Dispute status (`XA`–`XJ`, `XR` to remove) |

Common `account_status` codes (humanized atoms from `Metro2.Base.account_status/0`):

| Code | Atom | Meaning |
|---|---|---|
| 11 | `:current` | Current, no amount past due |
| 71, 78, 80, 82, 83, 84 | `:past_due_30_59` … `:past_due_180_plus` | 30–59 … 180+ days past due |
| 13 | `:closed` | Paid or closed, zero balance |
| 61–65 | `:paid_in_full_*` | Paid in full after a voluntary surrender, collection, repossession, charge-off or foreclosure |
| 05 | `:account_transferred` | Transferred to another office or servicer |
| 93 | `:collections` | Assigned to internal or external collections |
| 97 | `:charge_off` | Unpaid balance charged off |
| 88, 89, 94, 95, 96 | | Government insurance claim, deed in lieu, foreclosure completed, voluntary surrender, merchandise repossessed |
| DA, DF | `:delete_account`, `:delete_account_fraud` | Delete the account from the bureau's file (DF: due to fraud) |

**Consumer**

| Field | Purpose |
|---|---|
| `surname`, `first_name`, `middle_name`, `generation_code` | Name; `generation_code` is `:junior`, `:senior`, `:ii` … |
| `social_security_number`, `date_of_birth`, `telephone_number` | Identifiers the bureaus match on |
| `ecoa_code` | The consumer's relationship to the account: `:individual` (1), `:joint_contractual_liability` (2), `:authorized_user` (3), `:co_maker` (5), `:maker` (7), `:deceased` (X), `:delete_consumer` (Z), ... |
| `consumer_information_indicator` | Bankruptcy and similar events (`:petition_ch7`, `:discharged_ch13`, ...) |
| `consumer_transaction_type` | Signals a new account/borrower or a name, address or SSN change |
| `country_code`, `address_1`, `address_2`, `city`, `state`, `postal_code` | Current address |
| `address_indicator`, `residence_code` | Address type (`:confirmed`, `:military`, ...) and `:owns` / `:rents` |

## Appended segments

Optional segments written after the base record's 426 characters, always in the order
J1, J2, K1, K2, K3, K4, L1, N1. Add them with `Metro2.Records.BaseSegment.add_segment/2`.
J1 and J2 can appear several times per account; the others at most once.

| Segment | Length | Use it when |
|---|---|---|
| `J1Segment` — associated consumer, same address | 100 | Another consumer is on the account (joint borrower, authorized user, co-signer) and lives at the base consumer's address. Holds name, SSN, DOB, phone, ECOA code |
| `J2Segment` — associated consumer, different address | 200 | Same as J1, but the associated consumer lives elsewhere; adds a full address |
| `K1Segment` — original creditor | 34 | You are a collection agency or debt buyer: `original_creditor_name` and `creditor_classification` of who originally extended the credit |
| `K2Segment` — purchased from / sold to | 34 | The account was bought from or sold to another company. `purchased_from_sold_to_indicator`: `"1"` purchased from, `"2"` sold to, `"9"` remove previously reported K2 data |
| `K3Segment` — mortgage information | 40 | Mortgage accounts: agency (e.g. Fannie Mae, Freddie Mac) account number and the Mortgage Identification Number (MIN) |
| `K4Segment` — specialized payment | 30 | Balloon or deferred payments. `specialized_payment_indicator`: `"1"` balloon, `"2"` deferred; plus the relevant dates and balloon amount |
| `L1Segment` — account number change | 54 | The consumer account number and/or your identification number changed, so bureaus can link the old and new numbers. `change_indicator`: `"1"` account number, `"2"` identification number, `"3"` both |
| `N1Segment` — employment | 146 | Reporting the consumer's employer name, address and occupation |

## Tailer — `Metro2.Records.TailerSegment`

The last record of the file: counts of base records, of each account status, of each
appended segment type, of SSNs, dates of birth and telephone numbers, and of ECOA code Z.
Bureaus use these totals to confirm they received the whole file.

**You never fill the tailer.** `Metro2.File.serialize/1` and `Metro2.File.stream/2`
compute it from the base segments.
