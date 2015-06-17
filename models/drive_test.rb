require "google/api_client"
require "google_drive"

# Authorizes with OAuth and gets an access token.
# client = Google::APIClient.new
# auth = client.authorization
# auth.client_id = "102667004270-bgtkcdmj4g51h5bhdb4m2f25fur0t81c.apps.googleusercontent.com"
# auth.client_secret = "v_DYeoexedfeWcl_XI75Eyef"
# auth.scope = [
#   "https://www.googleapis.com/auth/drive",
#   "https://spreadsheets.google.com/feeds/",
#   "https://www.googleapis.com/auth/drive.readonly"
# ]
# auth.redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
# print("1. Open this page:\n%s\n\n" % auth.authorization_uri)
# print("2. Enter the authorization code shown in the page: ")
# auth.code = $stdin.gets.chomp
# auth.fetch_access_token!
# access_token = auth.access_token

# p "access_token:"
# p access_token


access_token = "ya29.jQEvl-42j0XD_7-rUTlfFTlAZtKzGu8wvOH-qTRZtmhStQfVjP_m32xtJf0ewh7j9dxFH-9Co_0oWg"

# Creates a session.
session = GoogleDrive.login_with_oauth(access_token)

# Gets list of remote files.
# session.files.each do |file|
#   p file.title
# end

input_coffee_folder_id = "0ByGnxs4KLeAoflpESEdFZU92NEp4UGo5Rlk0LWdreXNWSnFHUjRTVEVrRUM5TmM4eWpzaEE"

# session.files("q" => "'#{input_coffee_folder_id}' in parents").each do |file|
#   p file.title
# end

start = Time.now
all_files = session.files("q" => "'#{input_coffee_folder_id}' in parents")
stop = Time.now
puts "get all files: #{stop - start} sec"

#start = Time.now
a_file = all_files.first
contents = a_file.export_as_string("text/plain")
#stop = Time.now
#puts "get a file's contents: #{stop - start} sec"
#puts contents

#start = Time.now
contents_array = contents.split("\r\n")
contents_array.shift
meta_tag = "---"
meta_tag_count = 0
meta = {}
contents_array.each do |l|
  line = l.gsub(/<\/?[^>]*>/, '').gsub(/\n\n+/, "\n").gsub(/^\n|\n$/, '')
  if line != meta_tag && meta_tag_count < 1
    meta_line = line.split(": ")
    key = meta_line.first
    value = meta_line.last
    if key == "tags"
      value = value.split(" ")
    elsif key == "hours"
      value = value.to_f
    end
    meta[key] = value
  elsif line == meta_tag
    meta_tag_count += 1
  end
  break if meta_tag_count == 1
end
#stop = Time.now
#puts "process metadata: #{stop - start} sec"

puts meta

