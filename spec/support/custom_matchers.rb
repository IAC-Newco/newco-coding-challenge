require 'rspec/expectations'

STATUS_CODE_TO_SYMBOL = Rack::Utils::SYMBOL_TO_STATUS_CODE.invert.freeze

RSpec::Matchers.define :be_http_status do |expected|
  match do |actual|
    actual == Rack::Utils::SYMBOL_TO_STATUS_CODE[expected]
  end
  failure_message do |actual|
    actual_code = STATUS_CODE_TO_SYMBOL[actual]
    "expected that http status :#{actual_code} would be a http status :#{expected}"
  end
end
