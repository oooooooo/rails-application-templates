require 'awesome_print'
AwesomePrint.irb!

if defined? Rails::Console
  logger = Logger.new(STDOUT)
  ActiveRecord::Base.logger   = logger
  ActiveResource::Base.logger = logger

  if defined? Hirb
    Hirb.enable
  end
end
