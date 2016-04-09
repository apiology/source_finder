module SourceFinder
  # Globber for JavaScript
  module JsSourceFileGlobber
    attr_writer :js_dirs_arr, :extra_js_files_arr,
                :js_file_extensions_arr

    def js_dirs_arr
      @js_dirs_arr ||= %w(app src www)
    end

    def extra_js_files_arr
      @extra_js_files_arr ||= []
    end

    def js_file_extensions_arr
      arr = @js_file_extensions_arr if defined? @js_file_extensions_arr
      make_extensions_arr(arr, %w(js))
    end

    def js_file_extensions_glob
      js_file_extensions_arr.join(',')
    end

    def js_files_glob
      make_files_glob(extra_js_files_arr, js_dirs_arr,
                      js_file_extensions_glob)
    end

    def js_files_arr
      exclude_garbage(@globber.glob(js_files_glob) - exclude_files_arr)
    end
  end
end
