$:.unshift File.expand_path('../../lib/chef/knife', __FILE__)
require 'rspec'
require 'chef'

# RSpec.configure do |config|
#   config.before(:each) do
#     Chef::Config.reset
#     {
#       profitbricks_username: ENV['PROFITBRICKS_USERNAME'],
#       profitbricks_password: ENV['PROFITBRICKS_PASSWORD']
#     }.each do |key, value|
#       Chef::Config[:knife][key] = value
#     end
#   end
# end

# class Chef
#   class Knife
#   end
# end

# def get_image(image_name, image_type, image_location)
#   images = ProfitBricks::Image.list
#   min_image = nil
#   images.each do |image|

#     has_substring = image.properties['name'].downcase.include? image_name
#     if  image.properties['public'] == true && image.properties['imageType'] == image_type && image.properties['location'] == image_location && has_substring
#       min_image = image
#     end
#   end
#     min_image
# end

def get_request_id headers
  headers['Location'].scan(%r{/requests/(\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b)}).last.first
end

def is_done? request_id
  response = Ionoscloud::RequestApi.new.requests_status_get(request_id)
  if response.metadata.status == 'FAILED'
    ui.error "Request #{request_id} failed\n" + response.metadata.message
    exit(1)
  end
  response.metadata.status == 'DONE'
end
