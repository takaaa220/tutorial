User.create!(name: "admin",
      email: "admin@tutorial.com",
      password: "adminpass",
      password_confirmation: "adminpass",
      admin: true)

99.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name: name,
        email: email,
        password: password,
        password_confirmation: password)
end
