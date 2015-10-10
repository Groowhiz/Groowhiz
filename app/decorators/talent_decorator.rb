class TalentDecorator < Draper::Decorator
  decorates :talent
  include Draper::LazyHelpers


  def display_image(version = 'talent_thumb' )
    use_video_thumbnail(version)
  end

  def use_video_thumbnail(version)
    p "Source Thumbnail: #{source.talent_videos[0].video_thumbnail}"
    source.talent_videos[0].video_thumbnail
  end

  def get_video_url
    source.talent_videos[0].video_url
  end
end
