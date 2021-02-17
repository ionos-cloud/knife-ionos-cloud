require 'mustache'

$LOAD_PATH << '.'

Dir["../lib/chef/knife/*.rb"].each {|file| require file }


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

  attr_accessor :banner, :options, :example, :description, :name

  def initialize(banner, options, description, name)
    @banner = banner
    @options = options || []
    @example = banner.chomp('(options)').gsub!(/\[.*\] /,'') || banner.chomp('(options)') + (options.map { |el| el[:long]}).join(' ')
    @description = description
    @name = name
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
    value
  }

  subcommand_name = subcommand.class.to_s
  subcommand_name.slice!('Chef::Knife::Ionoscloud')

  filename = "subcommands/#{underscore_string(subcommand_name)}.md"

  begin
    description = subcommand.description
  rescue NoMethodError
    description = ''
  end

  File.open(filename, 'w') {|f| 
    f.write(
      Subcommand.new(
        subcommand.banner,
        options,
        description,
        subcommand_name,
      ).render,
    )
  }
  return subcommand_name, filename
end

subcommands = []

Chef::Knife.constants.select {|c|
  Chef::Knife.const_get(c).is_a?(Class) && c.to_s.start_with?('Ionoscloud') 
}.each {
  |subcommand|
  begin
    subcommand_name, filename = generate_subcommand_doc(Chef::Knife.const_get(subcommand).new)
    subcommands.append({ title: subcommand_name, filename: filename })
  rescue Exception => exc
    puts "could not generate doc for #{subcommand}"
    puts exc
    raise exc
  end
}

subcommands.sort! { |a,b| a[:title] <=> b[:title] }

File.open('summary.md', 'w') {|f| 
  f.write(Summary.new(subcommands).render,)
}
