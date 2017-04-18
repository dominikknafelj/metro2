defmodule Metro2.Records.HeaderSegment do

  alias Metro2.Fields.Alphanumeric
  alias Metro2.Fields.Numeric
  alias Metro2.Fields.Date

  defstruct [
    record_descriptor_word: %Numeric{ value: Metro2.Base.fixed_length, required_length: 4 },
    record_identifier: %Alphanumeric{ value: "HEADER", required_length: 6 },
    cycle_number: %Alphanumeric{ required_length: 2 },
    innovis_programm_identifier: %Alphanumeric{ required_length: 10 },
    equifax_programm_identifier: %Alphanumeric{ required_length: 10 },
    experian_programm_identifier: %Alphanumeric{ required_length: 5 },
    transunion_program_identifier: %Alphanumeric{ required_length: 10 },
    activity_date: %Date{},
    created_date: %Date{},
    program_date: %Date{},
    program_revisition_date: %Date{},
    reporter_name: %Alphanumeric{ required_length: 40 },
    reporter_address: %Alphanumeric{ required_length: 96, permitted_chars: Metro2.Base.alphanumeric_plus_dot_dash_slash  },
    reporter_telephone_number: %Numeric{ required_length: 10 },
    software_vendor_name: %Alphanumeric{ required_length: 40, value: "Metro2Elix" },
    software_version_number: %Alphanumeric{ required_length: 5, value: Metro2.Base.version_string },
    reserved: %Alphanumeric{ required_length: 156, value: nil }
   ]
end
