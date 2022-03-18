#!/usr/bin/env ruby

# This must be run from /docs directory

require 'mustache'
require 'fileutils'

$LOAD_PATH << '.'

Dir['../lib/chef/knife/*.rb'].each { |file| require file }

FOLDER_TO_NAME_MAP = {
  'backup' => 'Managed Backup',
  'user' => 'User Management',
  'compute-engine' => 'Compute Engine',
  'kubernetes' => 'Managed Kubernetes',
  'dbaas-postgres' => 'DBaaS Postgres',
}.freeze

def underscore_string(s)
  s.gsub(/::/, '/')
  .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
  .gsub(/([a-z\d])([A-Z])/, '\1_\2')
  .tr('-', '_')
  .downcase
end

class Subcommand < Mustache
  self.template_path = './templates'
  self.template_file = './templates/subcommand_doc.mustache'

  attr_accessor :banner, :options, :example, :description, :name, :required_options

  def initialize(banner, options, description, name, required_options)
    @banner = banner
    @options = options || []
    @example = banner.chomp('(options)').gsub!(/\[.*\] /, '') || banner.chomp('(options)') + (options.map { |el| el[:long] }).join(' ')
    @description = description
    @name = name
    @required_options = required_options || []
  end
end

class Summary < Mustache
  self.template_path = './templates'
  self.template_file = './templates/summary.mustache'

  attr_accessor :categories

  def initialize(categories)
    @categories = categories || []
  end
end

def generate_subcommand_doc(subcommand)
  options = subcommand.options.map do |key, value|
    value[:name] = key
    value[:required] = subcommand.required_options.include? key
    value[:description][0] = value[:description][0].downcase
    value
  end.rotate(3)

  subcommand_name = subcommand.class.to_s
  subcommand_name.slice!('Chef::Knife::Ionoscloud')

  begin
    filename = "subcommands/#{subcommand.directory}/#{underscore_string(subcommand_name)}.md"
    category = FOLDER_TO_NAME_MAP[subcommand.directory]
  rescue NoMethodError
    filename = "subcommands/#{underscore_string(subcommand_name)}.md"
    category = ''
  end

  begin
    description = subcommand.description
  rescue NoMethodError
    description = ''
  end

  FileUtils.mkdir_p(File.dirname(filename)) unless File.directory?(File.dirname(filename))

  File.open(filename, 'w') do |f|
    f.write(
      Subcommand.new(
        subcommand.banner,
        options,
        description,
        subcommand_name,
        subcommand.required_options.map { |el| el.to_s.gsub '_', '\_' },
      ).render,
    )
  end

  puts "Generated documentation for #{subcommand_name}."
  {
    title: subcommand_name,
    filename: filename,
    category: category,
  }
end

subcommands = []

begin
  Chef::Knife.constants.select do |c|
    Chef::Knife.const_get(c).is_a?(Class) && c.to_s.start_with?('Ionoscloud')
  end.each do |subcommand|
    # if subcommand.to_s == 'IonoscloudBackupunitCreate'
    begin
      subcommands.append(generate_subcommand_doc(Chef::Knife.const_get(subcommand).new))
    rescue StandardError => exc
      puts "Could not generate doc for #{subcommand}. Error: #{exc}"
      # raise exc
    end
    # end
  end
rescue NameError => exc
  puts 'This must be run from /docs directory!' if exc.message == 'uninitialized constant Chef'
  raise exc
end

categories = {}

subcommands.map do |subcommand|
  if categories.key?(subcommand[:category])
    categories[subcommand[:category]] << subcommand
  else
    categories[subcommand[:category]] = [subcommand]
  end
end


final_categories = []

categories.map { |key, value| final_categories << { category: key, subcommands: value.sort_by { |a| a[:title] } } }

File.open('summary.md', 'w') do |f|
  f.write(Summary.new(final_categories).render)
end
