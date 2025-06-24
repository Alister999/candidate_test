 # encoding: utf-8

@UI
Feature: UI Testing

  @get @smoke
  Scenario: working with cucumber web page

    Given захожу на страницу "http://google.com"
    When ввожу в поисковой строке текст "cucumber.io"
    When кликаю по строке выдачи с адресом https://cucumber.io
    And я должен увидеть текст на странице "Cucumber"
    

@get @smoke
  Scenario: working with ruby web page

    Given захожу на страницу "https://www.ruby-lang.org/ru/"
    When кликаю по кнопке перехода в загрузки
    When кликаю по ссылке на последнюю стейбл версию

    Then файл находится в директории загрузок
    And имя скачанного файла совпадает с указанным на сайте