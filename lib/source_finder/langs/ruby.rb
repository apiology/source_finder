module SourceFinder
  # Globber for Ruby
  module RubySourceFileGlobber
    attr_accessor :ruby_dirs_arr, :extra_ruby_files_arr,
                  :ruby_file_extensions_glob,
                  :ruby_file_extensions_arr

    def ruby_dirs_arr
      @ruby_dirs_arr ||= %w(app config db feature lib spec src test)
    end

    def extra_ruby_files_arr
      @extra_ruby_files_arr ||= %w(Rakefile)
    end

    # XXX: Add this to other languages as well--pull out pattern?
    def ruby_file_extensions_arr
      if @ruby_file_extensions_glob
        fail "glob already set, can't retrieve arr from extension glob"
      else
        @ruby_file_extensions_arr || %w(gemspec rake rb)
      end
    end

    def ruby_file_extensions_glob
      @ruby_file_extensions_glob || ruby_file_extensions_arr.join(',')
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
