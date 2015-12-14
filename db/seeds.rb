# coding: utf-8

puts 'Seeding the database...'

[
  { pt: 'Singing', en: 'Singing', fr: 'Singing'},
  { pt: 'Song Writing', en: 'Song Writing', fr: 'Song Writing' },
  { pt: 'Instrumental', en: 'Instrumental', fr: 'Instrumental' },
  { pt: 'Music Composition', en: 'Music Composition', fr: 'Music Composition' },
  { pt: 'Rock Band/Collaboration', en: 'Rock Band/Collaboration', fr: 'Rock Band/Collaboration' },
  { pt: 'Music teaching', en: 'Music teaching', fr: 'Music teaching' },
  { pt: 'Music Production', en: 'Music Production', fr: 'Music Production' },
  { pt: 'Music Technology', en: 'Music Technology', fr: 'Music Technology' },
  { pt: 'Music Management', en: 'Music Management', fr: 'Music Management' },
].each do |name|
   category = Category.find_or_initialize_by(name_pt: name[:pt])
   category.update_attributes({
     name_en: name[:en]
   })
   category.update_attributes({
     name_fr: name[:fr]
   })
 end

[
  { pt: 'Classical(Indian/western)', en: 'Classical(Indian/western)', fr: 'Classical(Indian/western)'},
  { pt: 'Rock', en: 'Rock', fr: 'Rock' },
  { pt: 'Pop', en: 'Pop', fr: 'Pop' },
  { pt: 'Jazz', en: 'Jazz', fr: 'Jazz' },
  { pt: 'R&B/Soul', en: 'R&B/Soul', fr: 'R&B/Soul' },
  { pt: 'Traditional/Folk', en: 'Traditional/Folk', fr: 'Traditional/Folk' },
  { pt: 'Hip-Hop/Rap', en: 'Hip-Hop/Rap', fr: 'Hip-Hop/Rap' },
  { pt: 'EDM(Electronic Dance Music)', en: 'EDM(Electronic Dance Music)', fr: 'EDM(Electronic Dance Music)' },
  { pt: 'Religious', en: 'Religious', fr: 'Religious' },
  { pt: 'Fusion', en: 'Fusion', fr: 'Fusion' },
  { pt: 'Film & television', en: 'Film & television', fr: 'Film & television' },
  { pt: 'Anime/Children’s Music', en: 'Anime/Children’s Music', fr: 'Anime/Children’s Music' },
  { pt: 'Soundtrack', en: 'Soundtrack', fr: 'Soundtrack' },
  { pt: 'New Age', en: 'New Age', fr: 'New Age' },
  { pt: 'World Music', en: 'World Music', fr: 'World Music' },
].each do |name|
   genre = Genre.find_or_initialize_by(name_pt: name[:pt])
   genre.update_attributes({
     name_en: name[:en]
   })
   genre.update_attributes({
     name_fr: name[:fr]
   })
 end

 [
  { pt: 'Andhra Pradesh', en: 'Andhra Pradesh', fr: 'Andhra Pradesh'},
  { pt: 'Arunachal Pradesh', en: 'Arunachal Pradesh', fr: 'Arunachal Pradesh' },
  { pt: 'Assam', en: 'Assam', fr: 'Assam' },
  { pt: 'Bihar', en: 'Bihar', fr: 'Bihar' },
  { pt: 'Chhattisgarh', en: 'Chhattisgarh', fr: 'Chhattisgarh' },
  { pt: 'Goa', en: 'Goa', fr: 'Goa' },
  { pt: 'Gujarat', en: 'Gujarat', fr: 'Gujarat' },
  { pt: 'Haryana', en: 'Haryana', fr: 'Haryana' },
  { pt: 'Himachal Pradesh', en: 'Himachal Pradesh', fr: 'Himachal Pradesh' },
  { pt: 'Jammu & Kashmir', en: 'Jammu & Kashmir', fr: 'Jammu & Kashmir' },
  { pt: 'Jharkhand', en: 'Jharkhand', fr: 'Jharkhand' },
  { pt: 'Karnataka', en: 'Karnataka', fr: 'Karnataka' },
  { pt: 'Kerala', en: 'Kerala', fr: 'Kerala' },
  { pt: 'Madhya Pradesh', en: 'Madhya Pradesh', fr: 'Madhya Pradesh' },
  { pt: 'Maharashtra', en: 'Maharashtra', fr: 'Maharashtra' },
  { pt: 'Manipur', en: 'Manipur', fr: 'Manipur'},
  { pt: 'Meghalaya', en: 'Meghalaya', fr: 'Meghalaya' },
  { pt: 'Mizoram', en: 'Mizoram', fr: 'Mizoram' },
  { pt: 'Nagaland', en: 'Nagaland', fr: 'Nagaland' },
  { pt: 'Odisha(Orissa)', en: 'Odisha(Orissa)', fr: 'Odisha(Orissa)' },
  { pt: 'Punjab', en: 'Punjab', fr: 'Punjab' },
  { pt: 'Rajasthan', en: 'Rajasthan', fr: 'Rajasthan' },
  { pt: 'Sikkim', en: 'Sikkim', fr: 'Sikkim' },
  { pt: 'Tamil Nadu', en: 'Tamil Nadu', fr: 'Tamil Nadu' },
  { pt: 'Telangana', en: 'Telangana', fr: 'Telangana' },
  { pt: 'Tripura', en: 'Tripura', fr: 'Tripura' },
  { pt: 'Uttar Pradesh', en: 'Uttar Pradesh', fr: 'Uttar Pradesh' },
  { pt: 'Uttarakhand', en: 'Uttarakhand', fr: 'Uttarakhand' },
  { pt: 'West Bengal', en: 'West Bengal', fr: 'West Bengal' },
 ].each do |name|
   state = State.find_or_initialize_by(name_pt: name[:pt])
   state.update_attributes({
     name_en: name[:en]
   })
   state.update_attributes({
     name_fr: name[:fr]
   })
 end

{
  company_name: 'TalentOxide',
  company_logo: 'http://talentoxide.com/assets/catarse_bootstrap/TO2_logo.png',
  host: 'talentoxide.com',
  base_url: "http://talentoxide.com",

  email_contact: 'talentoxide@gmail.com',
  email_payments: 'financeiro@catarse.me',
  email_projects: 'projetos@catarse.me',
  email_system: 'system@catarse.me',
  email_no_reply: 'no-reply@catarse.me',
  facebook_url: "https://www.facebook.com/Talent-Oxide-1568078490140357",
  facebook_app_id: '173747042661491',
  twitter_url: 'http://twitter.com/catarse',
  twitter_username: "catarse",
  mailchimp_url: "http://catarse.us5.list-manage.com/subscribe/post?u=ebfcd0d16dbb0001a0bea3639&amp;id=149c39709e",
  catarse_fee: '0.13',
  support_forum: 'http://suporte.catarse.me/',
  base_domain: 'talentoxide.com',
  uservoice_secret_gadget: 'change_this',
  uservoice_key: 'uservoice_key',
  faq_url: 'http://suporte.catarse.me/',
  feedback_url: 'http://suporte.catarse.me/forums/103171-catarse-ideias-gerais',
  terms_url: 'http://suporte.catarse.me/knowledgebase/articles/161100-termos-de-uso',
  privacy_url: 'http://suporte.catarse.me/knowledgebase/articles/161103-pol%C3%ADtica-de-privacidade',
  about_channel_url: 'http://blog.catarse.me/conheca-os-canais-do-catarse/',
  instagram_url: 'http://instagram.com/catarse_',
  blog_url: "http://blog.catarse.me",
  github_url: 'http://github.com/catarse',
  contato_url: 'http://suporte.catarse.me/'
}.each do |name, value|
   conf = CatarseSettings.find_or_initialize_by(name: name)
   conf.update_attributes({
     value: value
   }) if conf.new_record?
end

OauthProvider.find_or_create_by!(name: 'facebook') do |o|
  o.key = 'your_facebook_app_key'
  o.secret = 'your_facebook_app_secret'
  o.path = 'facebook'
end

puts
puts '============================================='
puts ' Showing all Authentication Providers'
puts '---------------------------------------------'

OauthProvider.all.each do |conf|
  a = conf.attributes
  puts "  name #{a['name']}"
  puts "     key: #{a['key']}"
  puts "     secret: #{a['secret']}"
  puts "     path: #{a['path']}"
  puts
end


puts
puts '============================================='
puts ' Showing all entries in Configuration Table...'
puts '---------------------------------------------'

CatarseSettings.all.each do |conf|
  a = conf.attributes
  puts "  #{a['name']}: #{a['value']}"
end

Rails.cache.clear

puts '---------------------------------------------'
puts 'Done!'
