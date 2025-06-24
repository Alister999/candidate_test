 # encoding: utf-8

@UI
Feature: UI Testing

  @get @smoke
  Scenario: working with cucumber web page

    When захожу на страницу "http://google.com"
    When ввожу в поисковой строке текст "cucumber.io"
    When кликаю по строке выдачи с адресом https://cucumber.io
    When я должен увидеть текст на странице "Cucumber"
    

@get @smoke
  Scenario: working with ruby web page

    When захожу на страницу "https://www.ruby-lang.org/ru/"
    When кликаю по кнопке перехода в загрузки
    When кликаю по ссылке на последнюю стейбл версию

    Then файл находится в директории загрузок
    Then имя скачанного файла совпадает с указанным на сайте