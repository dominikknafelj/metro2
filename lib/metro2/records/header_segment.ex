defmodule Metro2.Records.HeaderSegment do
  @structure [
    {:numeric_const_field, :record_descriptor_word, 4, Metro2.Base.fixed_length},
    {:alphanumeric_const_field, :record_identifier, 6, "HEADER"},
    {:alphanumeric_field, :cycle_number, 2},
    {:alphanumeric_field, :innovis_program_identifier, 10},
    {:alphanumeric_field, :equifax_program_identifier, 10},
    {:alphanumeric_field, :experian_program_identifier, 5},
    {:alphanumeric_field, :transunion_program_identifier, 10},
    {:date_field, :activity_date},
    {:date_field, :created_date},
    {:date_field, :program_date},
    {:date_field, :program_revision_date},
    {:alphanumeric_field, :reporter_name, 40},
    {:alphanumeric_field, :reporter_address, 96, Metro2.Base.alphanumeric_plus_dot_dash_slash},
    {:numeric_field, :reporter_telephone_number, 10},
    {:alphanumeric_const_field, :software_vendor_name, 40, "MetroElix"},
    {:alphanumeric_const_field, :software_version_number, 5, Metro2.Base.version_string},
    {:alphanumeric_const_field, :reserved, 156, nil}
  ]

  def structure, do: @structure
end
