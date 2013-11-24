if %w(production development).include?(PADRINO_ENV)
  require 'newrelic_moped'
  require 'newrelic_rpm'
end