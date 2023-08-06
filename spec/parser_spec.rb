# frozen_string_literal: true

RSpec.describe Parser do
  include Capybara::DSL

  let(:url) { 'https://rezka.ag/' }
  subject(:parser) { Parser.new(url) }

  it 'sets up Capybara with selenium_chrome driver and maximizes window' do
    visit(url)
    expect(current_url).to eq(url)
    page.driver.browser.manage.window
    expect(Capybara.current_driver).to eq(:selenium_chrome)
  end

  it 'find_matching_link_in_page' do
    links = ['Вход', 'Sign In', 'Увійти', 'Login', 'Log in']
    found_link = parser.find_matching_link_in_page(links)
    expect(found_link).not_to be_nil
  end

  it 'click_button_find_matching_link_in_page' do
    links = ['Вход', 'Sign In', 'Увійти', 'Login', 'Log in']
    found_link = parser.find_matching_link_in_page(links)
    expect(found_link).not_to be_nil
    visit(@url) # Перевіряємо, що знайдений посилання є на сторінці
    expect(page).to have_link(found_link)
    click_on(found_link) # Клікаємо на знайдений посилання
    expect(page).to have_field('login_name') # Перевіряємо, що поля для вводу логіну та пароля є на сторінці після кліку
    expect(page).to have_field('login_password')
  end

  describe 'click_login_button' do
    it 'should call visit with the given URL and click_on with the item' do
      item = 'Войти'
      expect(parser).to respond_to(:click_login_button)
      method_object = parser.method(:click_login_button)
      expect(method_object.arity).to eq(1)
      expect(parser).to receive(:click_on).with(item)
      expect(parser).to receive(:fill_in).with('login_name', with: 'hdrezka_pars')
      expect(parser).to receive(:fill_in).with('login_password', with: 'C2j85@Pi.zJDnm-')
      expect(parser).to receive(:click_on).with(item)
      expect(parser).to receive(:find_link).with('Выход', visible: :all).and_return(double(visible?: true))
      parser.click_login_button(item)
    end
  end

  describe 'search_movie' do
    it 'should fill in the search field with the given movie and click "Начать поиск" button' do
      movie = 'Terminator'
      expect(parser).to receive(:fill_in).with('q', with: movie)
      expect(parser).to receive(:click_button).with('Начать поиск')
      parser.search_movie(movie)
    end
  end


  describe 'create_csv_file' do
    it 'creates a CSV file with correct movie data' do
      movie_data_list = [
        {
          'Рейтини' => '8.5', 'Слоган' => 'Some movie slogan', 'Дата выхода' => '2023-01-01',
          'Страна' => 'USA', 'Жанр' => 'Action', 'В качестве' => 'HD', 'В переводе' => 'Subtitle',
          'Возраст' => '18+', 'Время' => '120 мин.', 'Из серии' => 'Yes'
        },

        {
          'Рейтини' => '7.8', 'Слоган' => 'Another movie slogan', 'Дата выхода' => '2023-02-15',
          'Страна' => 'Canada', 'Жанр' => 'Comedy', 'В качестве' => 'SD', 'В переводе' => 'Dubbed',
          'Возраст' => '12+', 'Время' => '105 мин.', 'Из серии' => 'No'
        }
      ]

      file_name = 'movie_data' # Задаємо ім'я файлу та шлях до папки data
      data_dir = 'data'
      file_path = "#{data_dir}/#{file_name}.csv"
      File.delete(file_path) if File.exist?(file_path) # Видаляємо файл, якщо він існує перед виконанням тесту
      parser.create_csv_file(file_name, movie_data_list) # Викликаємо метод create_csv_file для збереження даних у CSV-файл
      expect(File.exist?(file_path)).to be(true) # Перевірка чи файл був створений
      csv_data = CSV.read(file_path) # Перевірка вмісту CSV-файлу
      expect(csv_data.size).to eq(3) # Перевірка кількості рядків (заголовок + 2 рядки даних)
      expect(csv_data[0]).to eq(['Рейтини', 'Слоган', 'Дата выхода', 'Страна', 'Жанр', 'В качестве', 'В переводе', 'Возраст', 'Время', 'Из серии']) # Перевірка заголовку
      expect(csv_data[1]).to eq(['8.5', 'Some movie slogan', '2023-01-01', 'USA', 'Action', 'HD', 'Subtitle', '18+', '120 мин.', 'Yes']) # Перевірка першого рядка даних
      expect(csv_data[2]).to eq(['7.8', 'Another movie slogan', '2023-02-15', 'Canada', 'Comedy', 'SD', 'Dubbed', '12+', '105 мин.', 'No']) # Перевірка другого рядка даних
    end
  end
end
