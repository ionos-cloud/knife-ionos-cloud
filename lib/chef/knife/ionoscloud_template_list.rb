require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudTemplateList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud template list'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieve a list of available templates. Templates can be used on specific server types only (CUBE at the moment)'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        template_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Cores', :bold),
          ui.color('RAM', :bold),
          ui.color('Storage Size', :bold),
        ]
        templates_api = Ionoscloud::TemplatesApi.new(api_client)

        templates_api.templates_get({ depth: 1 }).items.sort do |a, b|
          a.properties.cores != b.properties.cores ? a.properties.cores <=> b.properties.cores : a.properties.ram <=> b.properties.ram
        end.each do |template|
          template_list << template.id
          template_list << template.properties.name
          template_list << Integer(template.properties.cores)
          template_list << Integer(template.properties.ram)
          template_list << Integer(template.properties.storage_size)
        end

        puts ui.list(template_list, :uneven_columns_across, 5)
      end
    end
  end
end
