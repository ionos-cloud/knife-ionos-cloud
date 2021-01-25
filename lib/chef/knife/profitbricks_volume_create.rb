require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksVolumeCreate < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks volume create (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'Name of the data center'

      option :name,
             short: '-n NAME',
             long: '--name NAME',
             description: 'Name of the volume'

      option :size,
             short: '-S SIZE',
             long: '--size SIZE',
             description: 'The size of the volume in GB'

      option :bus,
             short: '-b BUS',
             long: '--bus BUS',
             description: 'The bus type of the volume (VIRTIO or IDE)'

      option :image,
             short: '-N ID',
             long: '--image ID',
             description: 'The image or snapshot ID'

       option :imagealias,
              long: '--image-alias IMAGE_ALIAS',
              description: '(required) The image alias'

      option :imagepassword,
             short: '-P PASSWORD',
             long: '--image-password PASSWORD',
             description: 'The password set on the image for the "root" or "Administrator" user'

      option :type,
             short: '-t TYPE',
             long: '--type TYPE',
             description: 'The disk type (HDD OR SSD)'

      option :licencetype,
             short: '-l LICENCE',
             long: '--licence-type LICENCE',
             description: 'The licence type of the volume (LINUX, WINDOWS, UNKNOWN, OTHER)'

      option :sshkeys,
             short: '-K SSHKEY[,SSHKEY,...]',
             long: '--ssh-keys SSHKEY1,SSHKEY2,...',
             description: 'A list of public SSH keys to include',
             proc: proc { |sshkeys| sshkeys.split(',') }

      option :volume_availability_zone,
             short: '-Z AVAILABILITY_ZONE',
             long: '--availability-zone AVAILABILITY_ZONE',
             description: 'The volume availability zone of the server',
             required: false

      def run
        $stdout.sync = true
        validate_required_params(%i(datacenter_id name type size), config)

        if !config[:image] && !config[:imagealias]
          ui.error("Either '--image' or '--image-alias' parameter must be provided")
          exit(1)
        end

        if !config[:sshkeys] && !config[:imagepassword]
          ui.error("Either '--image-password' or '--ssh-keys' parameter must be provided")
          exit(1)
        end

        print "#{ui.color('Creating volume...', :magenta)}"

        params = {
          name: config[:name],
          size: config[:size],
          bus: config[:bus] || 'VIRTIO',
          type: config[:type],
          licenceType: config[:licencetype],
        }

        if config[:image]
          params[:image] = config[:image]
        end

        if config[:imagealias]
          params[:imageAlias] = config[:imagealias]
        end

        if config[:sshkeys]
          params[:sshKeys] = config[:sshkeys]
        end

        if config[:imagepassword]
          params[:imagePassword] = config[:imagepassword]
        end

        if config[:volume_availability_zone]
          params[:availabilityZone] = config[:volume_availability_zone]
        end


        volume_api = Ionoscloud::VolumeApi.new(api_client)

        volume, _, headers = volume_api.datacenters_volumes_post_with_http_info(
          config[:datacenter_id],
          { 'properties' => params.compact },
        )

        request_id = headers['Location'].scan(%r{/requests/(\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b)}).last.first

        dot = ui.color('.', :magenta)
        api_client.wait_for(300) { print dot; is_done? request_id }

        volume = volume_api.datacenters_volumes_find_by_id(config[:datacenter_id], volume.id)

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{volume.id}"
        puts "#{ui.color('Name', :cyan)}: #{volume.properties.name}"
        puts "#{ui.color('Size', :cyan)}: #{volume.properties.size}"
        puts "#{ui.color('Bus', :cyan)}: #{volume.properties.bus}"
        puts "#{ui.color('Image', :cyan)}: #{volume.properties.image}"
        puts "#{ui.color('Type', :cyan)}: #{volume.properties.type}"
        puts "#{ui.color('Licence Type', :cyan)}: #{volume.properties.licence_type}"
        puts "#{ui.color('Zone', :cyan)}: #{volume.properties.availability_zone}"
        puts 'done'
      end
    end
  end
end
