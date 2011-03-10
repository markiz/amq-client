# encoding: utf-8

if RUBY_VERSION.to_s =~ /^1.9/
  Encoding.default_internal = Encoding::UTF_8
  Encoding.default_external = Encoding::UTF_8
end


source :rubygems

gem "eventmachine", "0.12.10" #, "1.0.0.beta.3"
gem "amq-protocol", :path    => "vendor/amq-protocol"

group :development do
  gem "yard"
  # yard tags this buddy along
  gem "RedCloth"
  gem "cool.io" # , :path => "vendor/cool.io"

  gem "nake",          :platform => :ruby_19
  gem "contributors",  :platform => :ruby_19
end

group :test do
  gem "rspec", ">=2.0.0"
  gem "autotest"

  gem "em-spec",       :git => "https://github.com/tmm1/em-spec.git"
end
