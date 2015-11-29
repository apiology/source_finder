module SourceFinder
  # Give configuration, finds source file locations by using an
  # inclusion and exclusion glob
  class SourceFileGlobber
    # See README.md for documentation on these configuration parameters.
    attr_accessor :ruby_dirs_arr, :source_dirs_arr, :extra_source_files_arr,
                  :extra_ruby_files_arr, :ruby_file_extensions_arr,
                  :source_file_extensions_arr, :exclude_files_arr,
                  :source_files_glob, :source_files_exclude_glob,
                  :source_file_extensions_glob

    def initialize(globber: Dir)
      @globber = globber
    end

    def ruby_dirs_arr
      @ruby_dirs_arr ||= %w(src app config db lib test spec feature)
    end

    def source_dirs_arr
      @source_dirs_arr ||= ruby_dirs_arr.clone
    end

    def extra_source_files_arr
      @extra_source_files_arr ||=
        extra_ruby_files_arr.clone.concat(%w(Dockerfile))
    end

    def extra_ruby_files_arr
      @extra_ruby_files_arr ||= %w(Rakefile)
    end

    def default_source_files_exclude_glob
      '**/vendor/**'
    end

    def exclude_files_arr
      if @source_files_exclude_glob
        @globber.glob(@source_files_exclude_glob)
      elsif @exclude_files_arr
        @exclude_files_arr
      else
        @globber.glob(default_source_files_exclude_glob)
      end
    end

    def source_files_exclude_glob
      if @source_files_exclude_glob
        @source_files_exclude_glob
      elsif @exclude_files_arr
        "{#{exclude_files_arr.join(',')}}"
      else
        default_source_files_exclude_glob
      end
    end

    def source_file_extensions_arr
      @source_file_extensions_arr ||=
        ruby_file_extensions_arr +
        %w(swift cpp c java py clj cljs scala js yml sh json)
    end

    def doc_file_extensions_arr
      @doc_file_extensions_arr ||= %w(md)
    end

    def source_file_extensions_glob
      @source_file_extensions_glob ||= source_file_extensions_arr.join(',')
    end

    def source_and_doc_file_extensions_arr
      doc_file_extensions_arr + source_file_extensions_arr
    end

    def source_and_doc_file_extensions_glob
      @source_and_doc_file_extensions_glob ||=
        source_and_doc_file_extensions_arr.join(',')
    end

    def source_files_glob
      @source_files_glob ||
        make_files_glob(extra_source_files_arr, source_dirs_arr,
                        source_file_extensions_glob)
    end

    def source_and_doc_files_glob
      make_files_glob(extra_source_files_arr, source_dirs_arr,
                      source_and_doc_file_extensions_glob)
    end

    def make_files_glob(extra_source_files_arr,
                        dirs_arr,
                        extensions_glob)
      "{#{extra_source_files_arr.join(',')}," \
      "{*,.*}.{#{extensions_glob}}," +
        File.join("{#{dirs_arr.join(',')}}", '**',
                  "{*,.*}.{#{extensions_glob}}") + '}'
    end

    def ruby_file_extensions_arr
      @ruby_file_extensions_arr || %w(rb rake gemspec)
    end

    def ruby_file_extensions_glob
      @ruby_file_extensions_glob ||= ruby_file_extensions_arr.join(',')
    end

    def ruby_files_glob
      make_files_glob(extra_ruby_files_arr, ruby_dirs_arr,
                      ruby_file_extensions_glob)
    end

    def emacs_lockfile?(filename)
      File.basename(filename) =~ /^\.#/
    end

    def exclude_garbage(files_arr)
      files_arr.reject { |filename| emacs_lockfile?(filename) }
    end

    def ruby_files_arr
      exclude_garbage(@globber.glob(ruby_files_glob) - exclude_files_arr)
    end

    def source_files_arr
      exclude_garbage(@globber.glob(source_files_glob) - exclude_files_arr)
    end
  end
end
