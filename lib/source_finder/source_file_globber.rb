module SourceFinder
  # Give configuration, finds source file locations by using an
  # inclusion and exclusion glob
  class SourceFileGlobber
    # See README.md for documentation on these configuration parameters.

    attr_accessor :ruby_dirs, :source_dirs, :extra_files, :extra_ruby_files,
                  :ruby_file_extensions, :source_file_extensions,
                  :exclude_files, :source_files_glob, :source_files_exclude_glob

    def ruby_dirs
      @ruby_dirs ||= %w(src app lib test spec feature)
    end

    def source_dirs
      @source_dirs ||= ruby_dirs.clone
    end

    def extra_files
      @extra_files ||= extra_ruby_files.clone.concat(%w(Dockerfile))
    end

    def extra_ruby_files
      @extra_ruby_files ||= %w(Rakefile)
    end

    def exclude_files
      if @source_files_exclude_glob
        @globber.glob(@source_files_exclude_glob)
      else
        (@exclude_files || [])
      end
    end

    def source_file_extensions
      @source_file_extensions ||=
        "#{ruby_file_extensions},swift,cpp,c,java,py,clj,cljs,scala,js," \
        'yml,sh,json'
    end

    def source_files_glob(extra_source_files = extra_files,
                          dirs = source_dirs,
                          extensions = source_file_extensions)
      @source_files_glob ||
        "{#{extra_source_files.join(',')}," \
        "{*,.*}.{#{extensions}}," +
          File.join("{#{dirs.join(',')}}",
                    '**',
                    "{*,.*}.{#{extensions}}") +
          '}'
    end

    def source_files_exclude_glob
      @source_files_exclude_glob ||
        "{#{exclude_files.join(', ')}}"
    end

    def ruby_file_extensions
      @ruby_file_extensions ||= 'rb,rake,gemspec'
    end

    def ruby_files_glob
      source_files_glob(extra_ruby_files, ruby_dirs, ruby_file_extensions)
    end

    def ruby_files
      @globber.glob(ruby_files_glob) - exclude_files
    end

    def source_files
      @globber.glob(source_files_glob) - exclude_files
    end

    def initialize(globber: Dir)
      @globber = globber
    end
  end
end
