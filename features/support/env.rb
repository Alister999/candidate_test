# frozen_string_literal: true

require 'rest-client'
require 'active_support/all'
require_relative 'helpers/rest_wrapper'
require_relative 'helpers/logger'
require 'capybara/cucumber'
require 'selenium-webdriver'
require_relative 'helpers/class_extentions'

def browser_setup(browser = 'firefox')
  case browser
  when 'chrome'
    Capybara.register_driver :chrome do |app|
      downloads_dir = File.join(Dir.pwd, 'features/tmp')
      options = Selenium::WebDriver::Options.chrome
      options.add_argument('--disable-blink-features=AutomationControlled')
      options.add_argument('--disable-infobars')
      options.add_argument('--start-maximized')
      options.add_argument('--disable-extensions')
      options.add_argument('--disable-popup-blocking')
      options.add_argument('user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36')
      options.add_preference('download.default_directory', downloads_dir)
      options.add_preference('download.prompt_for_download', false)
      options.add_preference('plugins.plugins_disabled', ['Chrome PDF Viewer'])

      Selenium::WebDriver::Chrome.path = 'configuration/chromedriver' 

      Capybara::Selenium::Driver.new(app, browser: :chrome,
                                          options: options)

    end
    Capybara.default_driver = :chrome

    Capybara.page.driver.browser.manage.window.maximize
    Capybara.default_selector = :xpath
    Capybara.default_max_wait_time = 15
  else
    Capybara.register_driver :firefox_driver do |app|
      profile = Selenium::WebDriver::Firefox::Profile.new
      Selenium::WebDriver::Firefox.path = 'configuration/geckodriver'
      profile['browser.download.folderList'] = 2 
      profile['browser.download.dir'] = Dir.pwd + '/features/tmp/'
      profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/octet-stream, text/xml'
      profile['pdfjs.disabled'] = true
      Capybara::Selenium::Driver.new(app, browser: :firefox, profile: profile, port: Random.rand(7000..7999))
    end
    Capybara.default_driver = :firefox_driver
  end
end
browser_setup('chrome')

configuration = YAML.load_file 'configuration/default.yml'
$rest_wrap = RestWrapper.new url: 'https://testing4qa.ediweb.ru/api',
                             **configuration[:credentials]
logger_initialize
