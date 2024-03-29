#!/usr/bin/env ruby

# This must be run from /docs directory

require 'mustache'

$LOAD_PATH << '.'

Dir["../lib/chef/knife/*.rb"].each { |file| require file }

def underscore_string(s)
  s.gsub(/::/, '/').
  gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
  gsub(/([a-z\d])([A-Z])/, '\1_\2').
  tr("-", "_").
  downcase
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

  attr_accessor :subcommands

  def initialize(subcommands)
    @subcommands = subcommands || []
  end
end

def generate_subcommand_doc(subcommand)
  options = subcommand.options.map { |key, value|
    value[:name] = key
    value[:required] = subcommand.required_options.include? key
    value[:description][0] = value[:description][0].downcase
    value
  }.rotate(3)

  subcommand_name = subcommand.class.to_s
  subcommand_name.slice!('Chef::Knife::Ionoscloud')

  filename = "subcommands/#{underscore_string(subcommand_name)}.md"

  begin
    description = subcommand.description
  rescue NoMethodError
    description = ''
  end

  File.open(filename, 'w') { |f|
    f.write(
      Subcommand.new(
        subcommand.banner,
        options,
        description,
        subcommand_name,
        subcommand.required_options.map { |el| el.to_s.gsub '_', '\_' },
      ).render,
    )
  }

  puts "Generated documentation for #{subcommand_name}."
  return subcommand_name, filename
end

subcommands = []

begin
  Chef::Knife.constants.select { |c|
    Chef::Knife.const_get(c).is_a?(Class) && c.to_s.start_with?('Ionoscloud')
  }.each {
    |subcommand|
    begin
      subcommand_name, filename = generate_subcommand_doc(Chef::Knife.const_get(subcommand).new)
      subcommands.append({ title: subcommand_name, filename: filename })
    rescue Exception => exc
      puts "Could not generate doc for #{subcommand}. Error: #{exc}"
      # raise exc
    end
  }
rescue NameError => exc
  if exc.message == 'uninitialized constant Chef'
    puts 'This must be run from /docs directory!'
  end
  raise exc
end

subcommands.sort! { |a, b| a[:title] <=> b[:title] }

File.open('summary.md', 'w') { |f|
  f.write(Summary.new(subcommands).render,)
}
