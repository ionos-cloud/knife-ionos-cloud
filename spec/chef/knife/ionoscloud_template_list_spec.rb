require 'spec_helper'
require 'ionoscloud_template_list'

Chef::Knife::IonoscloudTemplateList.load_deps

describe Chef::Knife::IonoscloudTemplateList do
  before :each do
    subject { Chef::Knife::IonoscloudTemplateList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call TemplatesApi.templates_get' do
      templates = templates_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      template_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Cores', :bold),
        subject.ui.color('RAM', :bold),
        subject.ui.color('Storage Size', :bold),
        templates.items[0].id,
        templates.items[0].properties.name,
        Integer(templates.items[0].properties.cores),
        Integer(templates.items[0].properties.ram),
        Integer(templates.items[0].properties.storage_size),
        templates.items[1].id,
        templates.items[1].properties.name,
        Integer(templates.items[1].properties.cores),
        Integer(templates.items[1].properties.ram),
        Integer(templates.items[1].properties.storage_size),
      ]

      expect(subject.ui).to receive(:list).with(template_list, :uneven_columns_across, 5)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/templates',
            operation: :'TemplatesApi.templates_get',
            return_type: 'Templates',
            result: templates,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      required_options = subject.instance_variable_get(:@required_options)

      arrays_without_one_element(required_options).each do |test_case|

        test_case[:array].each { |value| subject.config[value] = 'test' }

        expect(subject).to receive(:puts).with("Missing required parameters #{test_case[:removed]}")
        expect(subject.api_client).not_to receive(:call_api)

        expect { subject.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end

        required_options.each { |value| subject.config[value] = nil }
      end
    end
  end
end
