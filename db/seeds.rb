# ユーザー
User.create!(name:  "管理者",
             email: "000@email.com",
             password:              "000000",
             password_confirmation: "000000",
             department: "管理者",
             employee_number: 000,
             admin:     true,
             superior: false,
             designated_start_time: Time.zone.parse("10:00"),
             designated_finish_time: Time.zone.parse("18:00"),
             uid: 000,
             basic_time: Time.zone.parse("7:30"),
            # specified_working_time: Time.zone.parse("8:00")
             )
             
User.create!(name:  "上長１",
             email: "111@email.com",
             password:              "111111",
             password_confirmation: "111111",
             department: "上長達",
             employee_number: 111,
             admin:     false,
             superior:  true,
             designated_start_time: Time.zone.parse("10:00"),
             designated_finish_time: Time.zone.parse("18:00"),
             uid: 111,
             basic_time: Time.zone.parse("7:30"),
            # specified_working_time: Time.zone.parse("8:00")
             )    

User.create!(name:  "上長２",
             email: "222@email.com",
             password:              "222222",
             password_confirmation: "222222",
             department: "上長達",
             employee_number: 222,
             admin:     false,
             superior:  true,
             designated_start_time: Time.zone.parse("15:00"),
             designated_finish_time: Time.zone.parse("23:00"),
             uid: 222,
             basic_time: Time.zone.parse("7:30"),
            # specified_working_time: Time.zone.parse("8:00")
             ) 
             
User.create!(name:  "一般１",
             email: "333@email.com",
             password:              "333333",
             password_confirmation: "333333",
             department: "一般ユーザー達",
             employee_number: 333,
             admin:     false,
             superior:  false,
             designated_start_time: Time.zone.parse("10:00"),
             designated_finish_time: Time.zone.parse("18:00"),
             uid: 333,
             basic_time: Time.zone.parse("7:30"),
            # specified_working_time: Time.zone.parse("8:00")
             )
             
User.create!(name:  "一般２",
             email: "444@email.com",
             password:              "444444",
             password_confirmation: "444444",
             department: "一般ユーザー達",
             employee_number: 444,
             admin:     false,
             superior:  false,
             designated_start_time: Time.zone.parse("10:00"),
             designated_finish_time: Time.zone.parse("18:00"),
             uid: 444,
             basic_time: Time.zone.parse("7:30"),
            # specified_working_time: Time.zone.parse("8:00")
             )

60.times do |n|
  name  = Faker::Name.name
  email = "xxx-#{n+1}@email.com"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               department: "一般ユーザー達",
               employee_number: "#{n+1}.to_i",
               admin:     false,
               superior:  false,
               designated_start_time: Time.zone.parse("10:00"),
               designated_finish_time: Time.zone.parse("18:00"),
               uid: "#{n+1}.to_s",
               basic_time: Time.zone.parse("7:30"),
              # specified_working_time: Time.zone.parse("8:00")
             )

end