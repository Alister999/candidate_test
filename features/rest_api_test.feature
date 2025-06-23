# encoding: utf-8

Feature: REST API Testing

  Scenario: Retrieve user list
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