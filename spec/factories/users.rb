FactoryBot.define do
  factory :user do
    name { 'John Doe' }
    email { 'john.doe@example.com' }
    phone { '+380000000000' }
    password { 'Password123!' }
    role { 'participant' }

    trait :admin do
      role { 'admin' }
    end

    trait :participant do
      role { 'participant' }
    end
  end
end
