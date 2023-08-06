require_relative 'lib/parser'
require 'uri'

puts 'Enter the URL:'
url = gets.chomp

puts 'Enter movie name:'
movie = gets.chomp

if url.empty?
  puts 'Error: URL cannot be empty.'
  exit
end

# Перевірка на коректність URL
begin
  uri = URI.parse(url)
  raise URI::InvalidURIError unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
rescue URI::InvalidURIError
  puts 'Error: Invalid URL format. Please provide a valid URL starting with http:// or https://'
  exit
end

parser = MovieParser.new(url)
links = ['Вход', 'Sign In', 'Увійти', 'Login', 'Log in']
item = parser.find_matching_link_in_page(links)

parser.click_login_button(item)
file_name = parser.search_movie(movie)

movie_data_list = parser.process_movies
parser.create_csv_file(file_name, movie_data_list)

puts "CSV file '#{file_name}.csv' created successfully."

