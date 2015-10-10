module Talent::VideoHandler
  extend ActiveSupport::Concern
  include Shared::VideoHandler

  included do
    # mount_uploader :video_thumbnail, TalentUploader

    def download_video_thumbnail
      # p "FUCKING SHIT #{self.inspect}"
      # self.video_thumbnail = open(self.video.thumbnail_large)  if self.video_valid?
      # p "FUCKING SHIT AFTER #{self.inspect}"
      # self.save
    rescue OpenURI::HTTPError, TypeError => e
      Rails.logger.info "-----> #{e.inspect}"
    end
  end
end
