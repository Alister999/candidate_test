# encoding: utf-8

Feature: REST API Testing

  Scenario: Adding new user to userlist
    When добавляю пользователя с параметрами:
      | login     | unique.user    |
      | name      | Alister         |
      | surname   | Lavey          |
      | password  | Pass123!     |
    When получаю информацию о пользователях
    Then проверяю наличие логина unique.user в списке пользователей
    When Проверяю соответствие данных пользователя с логином unique.user эталону:
      | login     | unique.user    |
      | name      | Alister         |
      | surname   | Lavey          |
      | password  | Pass123!     |
      | active    | 1            |
    When удаляю пользователя с логином unique.user

  Scenario: Delete user from user list
    When добавляю пользователя с параметрами:
      | login     | unique.user    |
      | name      | Alister         |
      | surname   | Lavey          |
      | password  | Pass123!     |
    When получаю информацию о пользователях
    Then проверяю наличие логина unique.user в списке пользователей
    When удаляю пользователя с логином unique.user
    When получаю информацию о пользователях
    Then проверяю отсутствие логина unique.user в списке пользователей


  Scenario: Change user in userlist
    When добавляю пользователя с параметрами:
      | login     | unique.user    |
      | name      | Alister         |
      | surname   | Lavey          |
      | password  | Pass123!     |
    When получаю информацию о пользователях
    Then проверяю наличие логина unique.user в списке пользователей
    When меняю параметры пользователя с логином unique.user:
      | login     | unique.user1    |
      | name      | Alister2         |
      | surname   | Lavey3          |
      | password  | Pass1234     |
      | active    | 2            |
    When Проверяю соответствие данных пользователя с логином unique.user1 эталону:
      | login     | unique.user1    |
      | name      | Alister2         |
      | surname   | Lavey3          |
      | password  | Pass1234     |
      | active    | 2            |
    When удаляю пользователя с логином unique.user1