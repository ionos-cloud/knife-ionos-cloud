# require 'spec_helper'
# require 'ionoscloud_k8s_list'

# Chef::Knife::IonoscloudK8sList.load_deps

# describe Chef::Knife::IonoscloudK8sList do
#   subject { Chef::Knife::IonoscloudK8sList.new }

#   before :each do
#     @cluster = create_test_k8s_cluster()
#     Ionoscloud::ApiClient.new.wait_for { cluster_check_state? @cluster.id }

#     allow(subject).to receive(:puts)
#   end

#   after :each do
#     Ionoscloud::KubernetesApi.new.k8s_delete(@cluster.id)
#   end

#   describe '#run' do
#     it 'should output the column headers and the datacenter' do
#       {
#         ionoscloud_username: ENV['IONOS_USERNAME'],
#         ionoscloud_password: ENV['IONOS_PASSWORD'],
#       }.each do |key, value|
#         subject.config[key] = value
#       end

#       expect(subject).to receive(:puts).with(
#         %r{
#           (^ID\s+Name\s+Version\s+Maintenance\sWindow\s+State\s*$\n.*
#           #{@cluster.id}\s+#{@cluster.properties.name.gsub(' ', '\s')}\s+
#           #{@cluster.properties.k8s_version}\s+
#           #{@cluster.properties.maintenance_window.day_of_the_week},\s
#           #{@cluster.properties.maintenance_window.time}\s+
#           #{@cluster.metadata.state}\s*$)
#         }x
#       )
#       subject.run
#     end
#   end
# end
