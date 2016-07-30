module SourceFinder
  # Globber for JavaScript
  module GroovySourceFileGlobber
    attr_writer :groovy_dirs_arr, :extra_groovy_files_arr,
                :groovy_file_extensions_arr

    def groovy_dirs_arr
      @groovy_dirs_arr ||= %w(app src var www)
    end

    def extra_groovy_files_arr
      @extra_groovy_files_arr ||= []
    end

    def groovy_file_extensions_arr
      arr = @groovy_file_extensions_arr if defined? @groovy_file_extensions_arr
      make_extensions_arr(arr, %w(groovy))
    end

    def groovy_file_extensions_glob
      groovy_file_extensions_arr.join(',')
    end

    def groovy_files_glob
      make_files_glob(extra_groovy_files_arr, groovy_dirs_arr,
                      groovy_file_extensions_glob)
    end

    def groovy_files_arr
      exclude_garbage(@globber.glob(groovy_files_glob) - exclude_files_arr)
    end
  end
end
