require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: notes
#
#  id                :integer         not null, primary key
#  notable_type      :string(255)
#  notable_id        :integer
#  note_title_id     :integer
#  custom_note_title :string(255)
#  content           :text
#  created_at        :timestamp
#  updated_at        :timestamp
#

