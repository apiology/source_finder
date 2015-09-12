require_relative 'source_file_globber'

module SourceFinder
  # Brings in command-line options to configure SourceFinder--usable
  # with the ruby OptionParser class, brought in with 'require
  # "optparse"'
  class OptionParser
    def fresh_globber
      SourceFinder::SourceFileGlobber.new
    end

    def default_source_files_glob
      fresh_globber.source_files_glob
    end

    def default_source_files_exclude_glob
      fresh_globber.source_files_exclude_glob
    end

    def add_glob_option(opts, options)
      opts.on('-g glob here', '--glob',
              'Which files to parse - ' \
              "default is #{default_source_files_glob}") do |v|
        options[:glob] = v
      end
    end

    def add_exclude_glob_option(opts, options)
      opts.on('-e glob here', '--exclude-glob',
              'Files to exclude - default is none') do |v|
        options[:exclude] = v
      end
    end

    def add_options(opts, options)
      add_glob_option(opts, options)
      add_exclude_glob_option(opts, options)
    end
  end
end
