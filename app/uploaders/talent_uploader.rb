# encoding: utf-8

class TalentUploader < ImageUploader

  version :talent_thumb
  version :talent_thumb_small
  version :talent_thumb_large
  version :talent_thumb_facebook

  def store_dir
    "uploads/talent/#{mounted_as}/#{model.id}"
  end

  version :talent_thumb do
    process resize_to_fill: [220,172]
    process convert: :jpg
  end

  version :talent_thumb_small, from_version: :talent_thumb do
    process resize_to_fill: [85,67]
    process convert: :jpg
  end

  version :talent_thumb_large do
    process resize_to_fill: [600,340]
    process convert: :jpg
  end

  #facebook requires a minimum thumb size
  version :talent_thumb_facebook do
    process resize_to_fill: [484,252]
    process convert: :jpg
  end

end
