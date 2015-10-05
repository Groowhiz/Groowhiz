class TalentImage < ActiveRecord::Base

  belongs_to :user
  belongs_to :talent

  # mount_uploader :uploaded_image, TalentUploader

end
