require 'pathname'
require './plugins/octopress_filters'

module Jekyll

  class IPythonNotebookTag < Liquid::Tag
    include OctopressFilters

    def initialize(tag_name, markup, tokens)
      @file = nil
      @raw = false
      if markup =~ /^(\S+)\s?(\w+)?/
        @file = $1.strip
        @raw = $2 == 'raw'
      end
      super
    end

    def render(context)
      file_dir = (context.registers[:site].source || 'source')
      file_path = Pathname.new(file_dir).expand_path
      file = file_path + @file

      unless file.file?
        return "File #{file} could not be found"
      end

      Dir.chdir(file_path) do
        system("ipython nbconvert %s --to html --template basic " % file)
        converted_file = Pathname.new(File.basename(@file, '.ipynb') + ".html")
        contents = converted_file.read
        FileUtils.rm converted_file.expand_path
        contents
      end
    end
  end
end

Liquid::Template.register_tag('notebook', Jekyll::IPythonNotebookTag)
