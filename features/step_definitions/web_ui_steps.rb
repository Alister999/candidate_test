# frozen_string_literal: true

When(/^захожу на страницу "(.+?)"$/) do |url|
  visit url
  $logger.info("Страница #{url} открыта")
  sleep 1
end

When(/^ввожу в поисковой строке текст "([^"]*)"$/) do |text|
  query = find("//textarea[@class='gLFyf']")
  query.set(text)
  query.native.send_keys(:enter)
  $logger.info("Поисковый запрос c текстом #{text} отправлен")
  sleep 1
end

When(/^кликаю по строке выдачи с адресом (.+?)$/) do |url|
  link_first = find("//a[@href='#{url}/']/h3")
  link_first.click
  $logger.info("Переход на страницу #{url} осуществлен")
  sleep 1
end

When(/^я должен увидеть текст на странице "([^"]*)"$/) do |text_page|
  sleep 1
  expect(page).to have_text text_page
  $logger.info("Текст #{text_page} на текущей странице присутствует")
end

When(/^кликаю по кнопке перехода в загрузки$/) do
  download_btn = all(:xpath, "//a[@href='/ru/downloads/']")
  download_btn[0].click
  $logger.info('Переход на страницу загрузок осуществлен')
  sleep 1
end

When(/^кликаю по ссылке на последнюю стейбл версию$/) do
  last_stables = all(:xpath, "//a[contains(@href, '.tar.gz') and contains(text(), 'Ruby 3')]")
  last_stables[0].click
  $logger.info('Клик по ссылке на последнюю стейбл версию осуществлен, начата загрузка')
end

Then(/^файл находится в директории загрузок$/) do
  last_stables = all(:xpath, "//a[contains(@href, '.tar.gz') and contains(text(), 'Ruby 3')]")
  site_name = last_stables[0][:href].split('/').last
  $logger.info("Имя скачиваемого файла с сайта: #{site_name}")

  downloads_dir = File.join(Dir.pwd, 'features/tmp')
  timeout = 20
  start_time = Time.now
  until Dir.glob(File.join(downloads_dir, site_name)).any? || (Time.now - start_time) > timeout
    $logger.info("Ожидаем скачивания файла #{site_name}, время ожидания: #{Time.now - start_time} секунд")
    sleep 1
  end
  if !Dir.glob(File.join(downloads_dir, site_name)).any?
    $logger.error("Файл #{site_name} не скачался за #{timeout} секунд")
    raise "Файл #{site_name} не скачался за #{timeout} секунд"
  else
    $logger.info("Файл #{site_name} успешно скачан в директорию #{downloads_dir}")
  end
end

Then(/^имя скачанного файла совпадает с указанным на сайте$/) do
  last_stables = all(:xpath, "//a[contains(@href, '.tar.gz') and contains(text(), 'Ruby 3')]")
  site_name = last_stables[0][:href].split('/').last
  downloads_dir = File.join(Dir.pwd, 'features/tmp')
  downloaded_file = Dir.glob(File.join(downloads_dir, site_name)).first
  $logger.info("имя скачанного файла: #{File.basename(downloaded_file)}, ожидаемое имя: #{site_name}")
  expect(File.basename(downloaded_file)).to eq site_name
  $logger.info("Имя скачанного файла #{File.basename(downloaded_file)} совпадает с ожидаемым #{site_name}")

  $logger.info("Удаляем файл #{site_name} из директории загрузок #{downloads_dir}")
  File.delete(downloaded_file) if downloaded_file && File.exist?(downloaded_file)
  $logger.info("Файл #{site_name} удалён из #{downloads_dir}")
rescue => e
  $logger.error("Ошибка при удалении файла: #{e.message}")
  raise
end
