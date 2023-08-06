# frozen_string_literal: true

require_relative '../lib/parser'
require 'capybara/dsl'
require 'dotenv/load'
require 'csv'

class MovieParser
  include Capybara::DSL

  def initialize(url)
    @url = url
    Capybara.current_driver = :selenium_chrome
    Capybara.register_driver :selenium do |app|
      capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
        chromeOptions: {
          args: %w[--disable-gpu]
        }
      )
      driver = Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
      configure_window_size(driver)
      driver
    end
  end

  # Шукаєм лінк на Логін
  def find_matching_link_in_page(links)
    visit(@url)
    page_body = page.body
    links.each do |link|
      return link if page_body.include?(link)
    end

    nil
  end

  def click_login_button(item)
    click_on(item)
    page.driver.browser.manage.window.maximize
    fill_in('login_name', with: ENV['REZKA_USERNAME'])
    fill_in('login_password', with: ENV['REZKA_PASSWORD'])
    click_on('Войти')
    find_link('Выход', visible: :all)
  rescue Capybara::Ambiguous
    puts 'Посилання не знайдено на сторінці'
  rescue Capybara::ElementNotFound
    puts 'Посилання "Выход" не знайдено на сторінці'
  end


  def search_movie(movie)
    fill_in('q', with: movie)
    click_button('Начать поиск')
    begin
      page.find('.b-content__htitle', wait: 10).text.split.last
    rescue Capybara::ElementNotFound
      puts "Помилка: Елемент з класом '.b-content__htitle' не знайдено на сторінці."
      '###' # Замініть на значення за замовчуванням, яке ви хочете встановити.
    end
  end

  def process_movies
    inline_items = all('.b-content__inline_items .b-content__inline_item')
    total_items = inline_items.count

    movie_data_list = [] # Список для збереження даних про фільми

    (0...total_items).each do |index|
      inline_items = all('.b-content__inline_items .b-content__inline_item')

      inline_item = inline_items[index]
      inline_item.find('.b-content__inline_item-cover a').click
      movie_data = get_movie_data # Отримуємо дані про фільм
      movie_data_list << movie_data # Додаємо дані про фільм до списку
      sleep(2)
      go_back
    end
    movie_data_list # Повертаємо список з даними про всі фільми
  end

  def get_movie_data
    data = {
      'Назва фільму' => nil,
      'Рейтинг' => '##',
      'Слоган' => '##',
      'Дата выхода' => '##',
      'Страна' => '##',
      'Режиссер' => '##',
      'Жанр' => '##',
      'В качестве' => '##',
      'В переводе' => '##',
      'Возраст' => '##',
      'Время' => '##',
      'Из серии' => '##'
    }

    data.each do |key, _|
      field_element = page.find(:xpath, "//td[contains(.,'#{key}')]/following-sibling::td")
      data[key] = field_element.text.strip
    rescue Capybara::ElementNotFound
      next if key == 'Назва фільму' # Назва фільму може бути відсутньою, і це не є помилкою

      data[key] = '##'
    end

    name_movie = page.find('.b-post__title h1').text # Змінна для назви фільму
    data['Назва фільму'] = name_movie # Додати назву фільму в хеш з даними
    data
  end

  def create_csv_file(file_name, movie_data)
    return if movie_data.empty?

    keys = movie_data.first.keys
    folder_name = 'data'

    Dir.mkdir(folder_name) unless Dir.exist?(folder_name)

    CSV.open("#{folder_name}/#{file_name}.csv", 'w', write_headers: true, headers: keys) do |csv|
      movie_data.each do |movie|
        csv << movie.values
      end
    end
  end

  private

  def configure_window_size(driver)
    return unless headless?(driver)

    driver.browser.manage.window.resize_to(1920, 1080)
  end

  def headless?(driver)
    driver.browser.options.args.include?('--headless')
  end
end
