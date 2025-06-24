# encoding: utf-8

@api
Feature: REST API Testing

  @get @smoke
  Scenario: Get users from userlist
    Given получаю информацию о пользователях
    Then проверяю наличие логина i.ivanov в списке пользователей
    Then проверяю соответствие данных пользователя эталону:
      | login     | i.ivanov       |
      | name      | Ivan           |
      | surname   | Ivanov         |
      | active    | 1              |
    Then проверяю отсутствие логина f.akelogin в списке пользователей

  @get @smoke
  Scenario: Get user from userlist
    Given получаю информацию о пользователях
    When позитивно получаю информацию о пользователe с айди 630:
    Then проверяю соответствие данных пользователя эталону:
      | login     | c.tester       |
      | name      | Ivan           |
      | surname   | Petrov         |
      | active    | 1              |

  @get @negative
  Scenario: Negative get user from userlist
    Given получаю информацию о пользователях
    When негативно получаю информацию о пользователe с айди 630:

  @post @smoke
  Scenario: Adding new user to userlist
    When позитивно добавляю пользователя с параметрами:
      | login     | unique.user    |
      | name      | Alister        |
      | surname   | Lavey          |
      | password  | Pass123!       |
    Given получаю информацию о пользователях
    Then проверяю наличие логина unique.user в списке пользователей
    Then проверяю соответствие данных пользователя эталону:
      | login     | unique.user    |
      | name      | Alister        |
      | surname   | Lavey          |
      | active    | 1              |
    And позитивно удаляю пользователя с логином unique.user

  @post @negative
  Scenario: Negative adding same user to userlist
    When негативно добавляю пользователя с параметрами:
      | login     | i.ivanov       |
      | name      | Alister        |
      | surname   | Lavey          |
      | password  | Pass123!       |

  @detete @smoke
  Scenario: Delete user from user list
    When позитивно добавляю пользователя с параметрами:
      | login     | unique.user    |
      | name      | Alister        |
      | surname   | Lavey          |
      | password  | Pass123!       |
    Given получаю информацию о пользователях
    Then проверяю наличие логина unique.user в списке пользователей
    And позитивно удаляю пользователя с логином unique.user
    Given получаю информацию о пользователях
    Then проверяю отсутствие логина unique.user в списке пользователей

  @detete @negative
  Scenario: Negative elete user from user list
    When негативно удаляю пользователя с логином unique.user
    Given получаю информацию о пользователях
    Then проверяю отсутствие логина unique.user в списке пользователей

  @put @smoke
  Scenario: Change user in userlist
    When позитивно добавляю пользователя с параметрами:
      | login     | unique.user    |
      | name      | Alister        |
      | surname   | Lavey          |
      | password  | Pass123!       |
    Given получаю информацию о пользователях
    Then проверяю наличие логина unique.user в списке пользователей
    When позитивно меняю параметры пользователя с логином unique.user:
      | login     | unique.user1   |
      | name      | Alister2       |
      | surname   | Lavey3         |
      | password  | Pass1234       |
      | active    | 2              |
    Given получаю информацию о пользователях
    Then проверяю отсутствие логина unique.user в списке пользователей
    Then проверяю соответствие данных пользователя эталону:
      | login     | unique.user1   |
      | name      | Alister2       |
      | surname   | Lavey3         |
      | active    | 2              |
    And позитивно удаляю пользователя с логином unique.user1

  @put @negative
  Scenario: Negative change user in userlist
    When позитивно добавляю пользователя с параметрами:
      | login     | unique.user    |
      | name      | Alister        |
      | surname   | Lavey          |
      | password  | Pass123!       |
    Given получаю информацию о пользователях
    Then проверяю наличие логина unique.user в списке пользователей
    When негативно меняю параметры пользователя с логином unique.user:
      | login     | unique.user1   |
      | name      | Alister2       |
      | surname   | Lavey3         |
      | password  | Pass1234       |
      | active    | 2              |
    And позитивно удаляю пользователя с логином unique.user

  @put @negative
  Scenario: Negative non arguments change user in userlist
    When позитивно добавляю пользователя с параметрами:
      | login     | unique.user    |
      | name      | Alister        |
      | surname   | Lavey          |
      | password  | Pass123!       |
    Given получаю информацию о пользователях
    Then проверяю наличие логина unique.user в списке пользователей
    When без_аргументов меняю параметры пользователя с логином unique.user:
      | login     ||
      | name      ||
      | surname   ||
      | password  ||
      | active    ||
    And позитивно удаляю пользователя с логином unique.user