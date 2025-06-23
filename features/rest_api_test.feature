# encoding: utf-8

@api
Feature: REST API Testing

  @get
  Scenario: Get users from userlist
    When получаю информацию о пользователях
    Then проверяю наличие логина i.ivanov в списке пользователей
    When Проверяю соответствие данных пользователя с логином i.ivanov эталону:
      | login     | i.ivanov    |
      | name      | Ivan         |
      | surname   | Ivanov          |
      | active    | 1            |
    Then проверяю отсутствие логина f.akelogin в списке пользователей

  @post
  Scenario: Adding new user to userlist
    When позитивно добавляю пользователя с параметрами:
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
      | active    | 1            |
    When удаляю пользователя с логином unique.user

  @post @negative
  Scenario: Adding same user to userlist
    When негативно добавляю пользователя с параметрами:
      | login     | i.ivanov    |
      | name      | Alister         |
      | surname   | Lavey          |
      | password  | Pass123!     |

  @detete
  Scenario: Delete user from user list
    When позитивно добавляю пользователя с параметрами:
      | login     | unique.user    |
      | name      | Alister         |
      | surname   | Lavey          |
      | password  | Pass123!     |
    When получаю информацию о пользователях
    Then проверяю наличие логина unique.user в списке пользователей
    When удаляю пользователя с логином unique.user
    When получаю информацию о пользователях
    Then проверяю отсутствие логина unique.user в списке пользователей

  @detete @negative
  Scenario: Delete user from user list
    When удаляю пользователя с логином unique.user
    When получаю информацию о пользователях
    Then проверяю отсутствие логина unique.user в списке пользователей

  @put
  Scenario: Change user in userlist
    When позитивно добавляю пользователя с параметрами:
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
    When получаю информацию о пользователях
    Then проверяю отсутствие логина unique.user в списке пользователей
    When Проверяю соответствие данных пользователя с логином unique.user1 эталону:
      | login     | unique.user1    |
      | name      | Alister2         |
      | surname   | Lavey3          |
      | active    | 2            |
    When удаляю пользователя с логином unique.user1