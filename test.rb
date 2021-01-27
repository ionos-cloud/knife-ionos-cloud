require 'ionoscloud'


Ionoscloud.configure do |config|
  config.username = ENV['IONOS_USERNAME']
  config.password = ENV['IONOS_PASSWORD']
end


servers = Ionoscloud::ServerApi.new.datacenters_servers_get('29c52a9d-848d-4f5f-a1b4-4650091c0a67', {depth: 1}).items

servers.each do |server|
  puts server.id
  puts server.properties.name
  puts server.properties.cores.to_s
  puts server.properties.ram.to_s
  puts server.properties.availability_zone
  puts server.properties.vm_state
  puts (server.properties.boot_volume == nil ? '' : server.properties.boot_volume.id)
  puts (server.properties.boot_cdrom == nil ? '' : server.properties.boot_cdrom.id)
end
