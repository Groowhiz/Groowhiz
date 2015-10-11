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

  def get_permalink
    p "Sourcerer : #{source.inspect}"
    source.permalink
  end

  def video_url?
    p "Hey llooo"
    video_url_present = true
    if source.talent_videos.size > 0
      if source.talent_videos[0].video_url.blank?
        video_url_present = false
      else
        video_url_present = true
      end
    else
      video_url_present = false
    end
    video_url_present
  end

  def status_icon_for group_name, action_name = nil
    if source.errors.present? && ( ['send_to_analysis', 'publish'].include? action_name )
      has_error = source.errors.any? do |error|
        source.error_included_on_group?(error, group_name)
      end

      if has_error
        content_tag(:span, '', class: 'fa fa-exclamation-circle fa-fw fa-lg text-error')
      else
        content_tag(:span, '', class: 'fa fa-check-circle fa-fw fa-lg text-success') unless source.published?
      end
    end
  end

  def display_errors group_name
    if source.errors.present?
      error_messages = ''
      source.errors.each do |error|
        if source.error_included_on_group?(error, group_name)
          error_messages += content_tag(:div, source.errors[error][0], class: 'fontsize-smaller')
        end
      end

      unless error_messages.blank?
        content_tag(:div, class: 'card card-error u-radius zindex-10 u-marginbottom-30') do
          content_tag(:div, I18n.t('failure_title'), class: 'fontsize-smaller fontweight-bold u-marginbottom-10') +
              error_messages.html_safe
        end
      end
    end
  end

  def display_video_embed_url
    if source.talent_videos[0].video_url
      "#{source.talent_videos[0].video_url}?title=0&byline=0&portrait=0&autoplay=0"
    end
  end
  
end
