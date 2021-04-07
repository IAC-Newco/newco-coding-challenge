module Util
  def response_json
    JSON[response_body]
  end
end
