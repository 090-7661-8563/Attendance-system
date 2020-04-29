source 'https://rubygems.org'

gem 'rails',                      '5.2.4'
gem 'rails-i18n'
gem 'bcrypt',                     '~> 3.1.11'
gem 'puma',                       '~>3.12.2'
gem 'faker',                      '1.7.3'
gem 'carrierwave',                '1.2.2'
gem 'mini_magick',                '~>4.9.4'
gem 'will_paginate',              '3.1.7'
gem 'kaminari-bootstrap',         '~> 3.0.1'
gem 'kaminari'
gem 'bootstrap-will_paginate',    '1.0.0'
gem 'sass-rails',                 '5.0.6'
gem 'uglifier',                   '3.2.0'
gem 'coffee-rails',               '4.2.2'
gem 'jquery-rails',               '4.3.1'
gem 'turbolinks',                 '5.0.1'
gem 'jbuilder',                   '2.7.0'
gem 'bootstrap-sass',             '~>3.4.1'
gem 'yard'
gem 'yard-activesupport-concern'
# for csv_import 
gem 'activerecord-import'
gem 'csv'
gem 'iconv'
gem 'roo'

group :development, :test do
  gem 'sqlite3',                  '1.3.13'
  gem 'byebug',                   '9.0.6', platform: :mri
end

group :development do
  gem 'web-console',              '3.5.1'
  gem 'listen',                   '3.1.5'
  gem 'spring',                   '2.0.2'
  gem 'spring-watcher-listen',    '2.0.1'
  
  # エラー画面をわかりやすく整形してくれる
  gem 'better_errors'
  # better_errorsの画面上にirb/pry(PERL)を表示する
  gem 'binding_of_caller' 
end

group :test do
  gem 'rails-controller-testing', '1.0.2'
  gem 'minitest-reporters',       '1.1.14'
  gem 'guard',                    '2.13.0'
  gem 'guard-minitest',           '2.4.4'
end

group :production do
  
  gem 'rails_12factor'
end

# Windows環境ではtzinfo-dataというgemを含める必要があります
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]