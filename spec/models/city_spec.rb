require 'rails_helper'

RSpec.describe City, type: :model do
  subject { create(:city) }

  describe "validations" do
    %w[name acronym].each do |field|
      it{ is_expected.to validate_presence_of field }
      it{ is_expected.to validate_uniqueness_of field }
    end
  end
end
