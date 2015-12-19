class GenreDecorator < Draper::Decorator
  decorates :genre
  include Draper::LazyHelpers


  def genre_display_name
    I18n.available_locales.include?(params[:locale].to_sym) ? source.send('name_'+params[:locale]) : source.name_pt
  end

end
