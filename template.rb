# $ cat ~/bin/railsnew
# rails new $1 -d mysql --skip-test-unit -m ~/work/rails-application-templates/template.rb

require 'erb'

#
# Ask
#

puts 'Please select a bootswatch theme.'
@bootswatch_themes = %w|unused cerulean cosmo cyborg darkly flatly journal lumen paper readable sandstone simplex slate spacelab superhero united yeti|
@bootswatch_themes.each_with_index do |theme, bootstrap_id|
  puts "#{bootstrap_id}. #{theme}"
end
bootstrap_id = ask("[0-#{@bootswatch_themes.size - 1}]:").to_i

if yes?('Use devise? [yN]')
  use_device = true
  if yes?('Use devise with LDAP? [yN]')
    use_device_with_ldap = true
  end
end

use_kaminari = true if yes?('Use kaminari? [yN]')

#
# def
#

def files(filename)
  ERB.new(File.read("#{File.dirname(__FILE__)}/files/#{filename}")).result(binding)
end

def run_bootswatch(bootstrap_id)
  copy_file 'app/assets/stylesheets/application.css', 'app/assets/stylesheets/application.scss'
  remove_file 'app/assets/stylesheets/application.css'

  gsub_file 'app/assets/stylesheets/application.scss', '*= require_tree', '*  require_tree'
  gsub_file 'app/assets/stylesheets/application.scss', '*= require_self', '*  require_self'

  insert_into_file 'app/assets/stylesheets/application.scss', after: "*/\n" do <<-CODE

@import "bootswatch/#{@bootswatch_themes[bootstrap_id]}/variables";

@import "bootstrap";
@import "font-awesome";

@import "bootswatch/#{@bootswatch_themes[bootstrap_id]}/bootswatch";
CODE
  end

  gsub_file 'app/views/layouts/application.html.erb', '<%= yield %>', %|<div class="container">\n<%= yield %>\n</div>|
end

def run_devise
  run 'rails g devise:install'
  run 'rails g devise user'
  run 'rails g devise:views:locale ja'
  run 'rails g devise:views:bootstrap_templates'
  run 'rails g cancan:ability'

  insert_into_file 'app/views/layouts/application.html.erb', after: "<body>\n" do <<-CODE

  <% if notice.present? %>
    <div class="alert alert-dismissable alert-success">
      <button type="button" class="close" data-dismiss="alert">&times;</button>
      <p><%= notice %></p>
    </div>
  <% end %>

  <% if alert.present? %>
    <div class="alert alert-dismissable alert-danger">
      <button type="button" class="close" data-dismiss="alert">&times;</button>
      <p><%= alert %></p>
    </div>
  <% end %>
CODE
  end

  insert_into_file 'app/controllers/application_controller.rb', before: 'end' do <<-CODE
  before_action :authenticate_user!
CODE
  end

  file = ''
  if File.exist?('app/assets/stylesheets/application.scss')
    file = 'app/assets/stylesheets/application.scss'
  else
    file = 'app/assets/stylesheets/application.css'
  end
  insert_into_file file, before: ' */' do <<-CODE
 *= require devise_bootstrap_views
CODE
  end
end

#
# Gemfile
#

run 'bundle update'

gem 'therubyracer', platforms: :ruby
gem 'unicorn'
#gem 'unicorn-rails'

gem_group :development do
  gem 'brakeman'
  gem 'rack-mini-profiler'
  gem 'rails-footnotes'
  gem 'rails_best_practices'
#   gem 'peek'
#   gem 'peek-mysql2'
#   gem 'peek-performance_bar'
#   gem 'peek-rblineprof'
#   gem 'pygments.rb', require: false # peek-rblineprof の syntax を highlight
end

gem_group :development, :test do
  gem 'awesome_print'
  gem 'better_errors'
    gem 'binding_of_caller'
  gem 'did_you_mean'
  gem 'bullet'
    gem 'xmpp4r'
  gem 'figaro'
  gem 'guard-brakeman', github: 'guard/guard-brakeman'
  gem 'guard-bundler'
  gem 'guard-livereload'
  gem 'guard-rails'
  gem 'guard-rails_best_practices', github: 'logankoester/guard-rails_best_practices' # Could not load 'guard/rails_best_practices'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'hirb'
  gem 'hirb-unicode'
  gem 'letter_opener'
  gem 'pry-alias' # bp で binding.pry
  gem 'pry-byebug'
  gem 'pry-coolline'
  gem 'pry-rails'
  gem 'quiet_assets'
  gem 'rack-dev-mark'
  gem 'rails-erd', github: 'ready4god2513/rails-erd', branch: 'rails-4.2-support-fix' # bundle exec erd
  gem 'rails-flog'
  gem 'rspec-rails'
  gem 'rubocop'
end

gem_group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'database_rewinder'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'fuubar' # The instafailing RSpec progress bar formatter
  gem 'launchy' # save and open page
  gem 'metric_fu'
#  gem 'parallel_tests'
  gem 'poltergeist'
#  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'simplecov-json'
  gem 'simplecov-rcov'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end

gem_group :production, :staging do
  gem 'rails_12factor'
end

gem 'rails_config'

gem 'airbrake'

gem 'exception_notification', git: 'https://github.com/smartinez87/exception_notification.git' # rails g exception_notification:install
gem 'slack-notifier'

gem 'email_validator'

gem 'bootstrap-sass'
  gem 'autoprefixer-rails'
gem 'bootswatch-rails'
gem 'browser'
gem 'font-awesome-rails'
gem 'kaminari'
gem 'slim-rails'

# gem 'chosen-rails'
# gem 'jquery-datetimepicker-rails'
# gem 'jquery-fileupload-rails'
# gem 'nprogress-rails'

# source 'https://rails-assets.org' do
#   gem 'rails-assets-knockout'
#   gem 'rails-assets-vue'
#   gem 'rails-timeago'
# end

# gem 'c3-rails'
# gem 'd3-rails'

# gem 'country_select', github: 'stefanpenner/country_select'
# gem 'holidays'
#   gem 'rails-i18n'
gem 'ungarbled' # 日本語ファイルの文字化け防止

gem 'net-ping'
gem 'net-ldap'
gem 'cancancan'
gem 'devise'
gem 'devise-bootstrap-views'
gem 'devise_ldap_authenticatable', git: 'https://github.com/cschiewek/devise_ldap_authenticatable.git'
gem 'devise-i18n-views'
gem 'devise-i18n'

gem 'activerecord-import'
gem 'paranoia'
gem 'ransack'
gem 'squeel', github: 'danielrhodes/squeel' # https://github.com/activerecord-hackery/squeel/issues/352

# gem 'sinatra', require: false
# gem 'sidekiq' # bundle exec sidekiq -q default -q mailers

gem 'whenever'

gem 'newrelic_rpm'

run 'bundle install'

#
# Files
#

# environment は 2 space を入れるので rails_best_practices 用に一行目は 2 space 削る
data =<<CODE
# https://github.com/charliesome/better_errors
  BetterErrors::Middleware.allow_ip! '192.168.0.0/9'

  # https://github.com/MiniProfiler/rack-mini-profiler
  Rack::MiniProfiler.config.position = 'left'

  # https://github.com/ryanb/letter_opener
  config.action_mailer.delivery_method = :letter_opener

  # https://github.com/dtaniwaki/rack-dev-mark
  config.rack_dev_mark.enable = true
CODE
environment data, env: :development

initializer 'airbrake.rb',               files('airbrake.erb')
initializer 'bullet.rb',                 files('bullet.erb')
initializer 'exception_notification.rb', files('exception_notification.erb') # run 'rails g exception_notification:install'

run_bootswatch(bootstrap_id) if bootstrap_id >= 1
run_devise if use_device
run 'rails g devise_ldap_authenticatable:install' if use_device_with_ldap
run 'rails g kaminari:views bootstrap3' if use_kaminari
run 'rails g rails_config:install'
run 'rails g rails_footnotes:install'
run 'rails g rspec:install'
run 'rails g squeel:initializer'
run 'bundle exec figaro install'

create_file 'bin/deploy.sh',                  files('deploy.sh')
chmod 'bin/deploy.sh', 0755

create_file 'bin/kill_unicorn.sh',            files('kill_unicorn.sh')
chmod 'bin/kill_unicorn.sh', 0755

remove_file '.gitignore'
create_file '.gitignore',                     files('.gitignore')

create_file 'config/newrelic.yml',            files('newrelic.yml') if ENV['NEWRELIC_LICENSE_KEY']
create_file 'config/nginx/conf.d/rails.conf', files('nginx/conf.d/rails.conf')
create_file 'config/unicorn.rb',              files('unicorn.rb')

insert_into_file 'config/application.rb', after: "# config.i18n.default_locale = :de\n" do <<-CODE
    config.i18n.default_locale = :ja
CODE
end

insert_into_file 'spec/rails_helper.rb', after: "# Add additional requires below this line. Rails is not loaded until this point!\n" do <<-CODE
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
require 'simplecov'
require 'simplecov-json'
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter,
  SimpleCov::Formatter::RcovFormatter
]
SimpleCov.start
CODE
end

after_bundle do
  run 'bundle exec guard init'
  gsub_file 'Guardfile', ':run_on_start => true', 'run_on_start: true, quiet: true'
  gsub_file 'Guardfile', "guard 'rails' do",      "guard 'rails', CLI: 'rails server -b 0.0.0.0' do"
  append_to_file 'Guardfile' do <<-CODE

guard :rails_best_practices, exclude: 'kaminari' do
  watch(%r{^app/(.+)\.rb$})
end
CODE
  end

  # rails_best_practices fix
  gsub_file 'config/initializers/devise.rb', '# ==> LDAP Configuration ', '# ==> LDAP Configuration' if use_device

  rake 'db:create'
  rake 'db:migrate'
  create_file "db/migrate/#{Time.now.strftime('%Y%m%d%H%M%S')}_create_tables.rb", files('create_tables.rb')
  remove_file Dir.glob('db/migrate/*_devise_create_users.rb').first if use_device

  remove_file 'public/index.html'
  remove_file 'app/assets/images/rails.png'
  remove_file 'README.rdoc'

  run 'rubocop --auto-correct app/'
  create_file      '.rubocop.yml', files(     '.rubocop.yml')
  create_file 'spec/.rubocop.yml', files('spec/.rubocop.yml')

  create_file '.rspec', files('.rspec')

  git :init
  git add: '.'
  git commit: %Q{ -m 'Initial commit' }
end
