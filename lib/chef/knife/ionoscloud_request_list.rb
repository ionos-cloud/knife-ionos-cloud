require_relative 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudRequestList < Knife
      include Knife::IonoscloudBase

      banner 'knife ionoscloud request list (options)'

      option :limit,
              short: '-l LIMIT',
              long: '--limit LIMIT',
              description: 'The maximum number of requests to look into.'

      option :offset,
              short: '-o OFFSET',
              long: '--offset OFFSET',
              description: 'The request number from which to return results.'

      option :status,
              short: '-s STATUS',
              long: '--status STATUS',
              description: 'Request status filter to fetch all the request based on a particular status [QUEUED, RUNNING, DONE, FAILED]'

      option :method,
              short: '-m METHOD',
              long: '--method METHOD',
              description: 'Request method filter to fetch all the request based on a particular method [POST, PUT, PATCH, DELETE]'

      attr_reader :description, :required_options

      def initialize(args = [])
        super(args)
        @description =
        'This operation allows you to retrieve a list of requests. Cloud API calls generate a '\
        'request which is assigned an id. This "request id" can be used to get information about '\
        'the request and its current status. The "list request" operation described here will '\
        'return an array of request items. Each returned request item will have an id that can be '\
        'used to get additional information as described in the Get Request and Get Request Status sections.'
        @required_options = [:ionoscloud_username, :ionoscloud_password]
      end

      def run
        $stdout.sync = true
        handle_extra_config
        validate_required_params(@required_options, config)

        request_list = [
          ui.color('ID', :bold),
          ui.color('Status', :bold),
          ui.color('Method', :bold),
          ui.color('Targets', :bold),
        ]

        request_api = Ionoscloud::RequestApi.new(api_client)

        begin
          config[:limit] = Integer(config[:limit])
        rescue *[ArgumentError, TypeError]
          if config[:limit]
            ui.warn('limit should be an Integer!')
          end
          config[:limit] = 20
        end

        begin
          config[:offset] = Integer(config[:offset])
        rescue *[ArgumentError, TypeError]
          if config[:offset]
            ui.warn('offset should be an Integer!')
          end
          config[:offset] = 0
        end

        opts = {
          depth: 2,
          limit: config[:limit],
          offset: config[:offset],
        }

        if config[:status] && ['QUEUED', 'RUNNING', 'DONE', 'FAILED'].include?(config[:status])
          opts[:filter_request_status] = config[:status]
        end

        if config[:status] && !['QUEUED', 'RUNNING', 'DONE', 'FAILED'].include?(config[:status])
          ui.warn('status should be one of [QUEUED, RUNNING, DONE, FAILED]')
        end

        if config[:method] && ['POST', 'PUT', 'PATCH', 'DELETE'].include?(config[:method])
          opts[:filter_method] = config[:method]
        end

        if config[:method] && !['POST', 'PUT', 'PATCH', 'DELETE'].include?(config[:method])
          ui.warn('method should be one of [POST, PUT, PATCH, DELETE]')
        end

        request_api.requests_get(opts).items.each do |request|
          request_list << request.id
          request_list << request.metadata.request_status.metadata.status
          request_list << request.properties.method
          request_list << request.metadata.request_status.metadata.targets.map { |target| [target.target.id, target.target.type] }.to_s
        end

        puts ui.list(request_list, :uneven_columns_across, 4)
      end
    end
  end
end
