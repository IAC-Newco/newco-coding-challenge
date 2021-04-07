require "faker"

FactoryBot.define do
  factory :post do |u|
    content { Faker::Lorem.sentence }
  end

end
