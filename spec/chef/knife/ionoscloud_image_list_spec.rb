require 'spec_helper'
require 'ionoscloud_image_list'

Chef::Knife::IonoscloudImageList.load_deps

describe Chef::Knife::IonoscloudImageList do
  before :each do
    subject { Chef::Knife::IonoscloudImageList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ImageApi.images_get' do
      images = images_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      image_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Location', :bold),
        subject.ui.color('Size', :bold),
        subject.ui.color('Public', :bold),
        subject.ui.color('Aliases', :bold),
        images.items.first.id,
        images.items.first.properties.name,
        images.items.first.properties.location,
        images.items.first.properties.size.to_s,
        images.items.first.properties.public.to_s,
        images.items.first.properties.image_aliases,
      ]

      expect(subject.ui).to receive(:list).with(image_list, :uneven_columns_across, 6)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/images',
            operation: :'ImageApi.images_get',
            return_type: 'Images',
            result: images,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      check_required_options(subject)
    end
  end
end
