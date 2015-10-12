# coding: utf-8

puts 'Seeding the database...'

[
  { pt: 'Art', en: 'Art', fr: 'Art'},
  { pt: 'Visual Arts', en: 'Visual Arts', fr: 'Visual Arts' },
  { pt: 'Circus', en: 'Circus', fr: 'Circus' },
  { pt: 'Humor', en: 'Humor', fr: 'Humor' },
  { pt: 'Quadrinhos', en: 'Comicbooks', fr: 'bd' },
  { pt: 'Dance', en: 'Dance', fr: 'Dance' },
  { pt: 'Design', en: 'Design', fr: 'Design' },
  { pt: 'Events', en: 'Events', fr: 'Events' },
  { pt: 'Fashion', en: 'Fashion', fr: 'Fashion' },
  { pt: 'Cooking', en: 'Cooking', fr: 'Cooking' },
  { pt: 'Film & Video', en: 'Film & Video', fr: 'Film & Video' },
  { pt: 'Games', en: 'Games', fr: 'Games' },
  { pt: 'Journalism', en: 'Journalism', fr: 'Journalism' },
  { pt: 'Music', en: 'Music', fr: 'Music' },
  { pt: 'Photography', en: 'Photography', fr: 'Photography' },
  { pt: 'Theatre', en: 'Theatre', fr: 'Theatre' },
  { pt: 'Sport', en: 'Sport', fr: 'Sport' },
  { pt: 'Carnival', en: 'Carnival', fr: 'Carnival' },
  { pt: 'Architecture & Urbanism', en: 'Architecture & Urbanism', fr: 'Architecture & Urbanism' },
  { pt: 'Literature', en: 'Literature', fr: 'Literature' },
  { pt: 'Documentary Films', en: 'Documentary Films', fr: 'Documentary Films' },
  { pt: 'Fiction Films', en: 'Fiction Films' , fr: 'Fiction Films'},
].each do |name|
   category = Category.find_or_initialize_by(name_pt: name[:pt])
   category.update_attributes({
     name_en: name[:en]
   })
   category.update_attributes({
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
