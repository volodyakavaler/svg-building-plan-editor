# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

user1 = User.create(
  email: "qwerty@yandex.ru",
  last_name:  "Пупкин",
  first_name: "Василий",
  patronymic: "Петрович",
  password:   "qwerty"
)

user1.save
