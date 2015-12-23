module SourceFinder
  # Globber for Ruby
  module RubySourceFileGlobber
    attr_accessor :ruby_dirs_arr, :extra_ruby_files_arr,
                  :ruby_file_extensions_arr

    def ruby_dirs_arr
      @ruby_dirs_arr ||= %w(app config db feature lib spec src test)
    end

    def extra_ruby_files_arr
      @extra_ruby_files_arr ||= %w(Rakefile)
    end

    def ruby_file_extensions_arr
      @ruby_file_extensions_arr || %w(gemspec rake rb)
    end

    def ruby_file_extensions_glob
      @ruby_file_extensions_glob ||= ruby_file_extensions_arr.join(',')
    end

    def ruby_files_glob
      make_files_glob(extra_ruby_files_arr, ruby_dirs_arr,
                      ruby_file_extensions_glob)
    end

    def ruby_files_arr
      exclude_garbage(@globber.glob(ruby_files_glob) - exclude_files_arr)
    end
  end
end
