require 'chef/knife/ionoscloud_base'

class Chef
  class Knife
    class IonoscloudImageList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud image list'

      def run
        $stdout.sync = true
        image_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Description', :bold),
          ui.color('Location', :bold),
          ui.color('Size', :bold),
          ui.color('Public', :bold)
        ]
        image_api = Ionoscloud::ImageApi.new(api_client)

        image_api.images_get({ depth: 1 }).items.each do |image|
          image_list << image.id
          image_list << image.properties.name
          image_list << image.properties.description
          image_list << image.properties.location
          image_list << image.properties.size.to_s
          image_list << image.properties.public.to_s
        end

        puts ui.list(image_list, :uneven_columns_across, 6)
      end
    end
  end
end