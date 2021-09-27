require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudRequestGet < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud request get (options)'

      option :request_id,
              short: '-R REQUEST_ID',
              long: '--request-id REQUEST_ID',
              description: 'The ID of the Request.'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'Retrieves the properties of a specific request based on the supplied request id.'
        @required_options = [:request_id, :ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        request = Ionoscloud::RequestApi.new(api_client).requests_find_by_id(config[:request_id], depth: 1)
        puts "#{ui.color('ID', :cyan)}: #{request.id}"
        puts "#{ui.color('Status', :cyan)}: #{request.metadata.request_status.metadata.status}"
        puts "#{ui.color('Method', :cyan)}: #{request.properties.method}"
        puts "#{ui.color('URL', :cyan)}: #{request.properties.url}"
        puts "#{ui.color('Targets', :cyan)}: #{request.metadata.request_status.metadata.targets.map { |target| [target.target.id, target.target.type] }.to_s}"
        puts "#{ui.color('Body', :cyan)}: #{request.properties.body}"
        puts "#{ui.color('Headers', :cyan)}: #{request.properties.headers}"
      end
    end
  end
end
