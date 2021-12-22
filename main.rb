require "uri"
require "net/http"
require "json"
require "pp"

DEBUG = false
# Permissions will be that of the user that created the token
AUTH_TOKEN = open('.snipe_auth_token').readline
# Formatted as https://your_snipe_url.io
URL = open('.snipe_url').readline

def make_request(url)
  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true

  request = Net::HTTP::Get.new(url)
  request["Accept"] = "application/json"
  request["Content-Type"] = "application/json"
  request["Authorization"] = "Bearer #{AUTH_TOKEN}"
  https.request(request)
end

def fetch_users
  url = URI("#{URL}/api/v1/users")
  response = make_request(url)

  JSON.parse(response.read_body)["rows"]
end

def fetch_user_assets(id)
  url = URI("#{URL}/api/v1/users/#{id}/assets")
  response =  make_request(url)

  JSON.parse(response.read_body)
end

user_list = fetch_users

print 'Which user: '
user_email = gets.chomp

selected_user = user_list.find { |user| user['email'] == user_email}
pp selected_user if DEBUG

data = fetch_user_assets(selected_user["id"])
pp(data) if DEBUG

puts "#{selected_user['name']} - Assets"
data['rows'].each do |asset|
  puts "\t#{asset['asset_tag']}"
end