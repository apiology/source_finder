module SourceFinder
  # Globber for Python
  module PythonSourceFileGlobber
    attr_accessor :python_dirs_arr, :extra_python_files_arr,
                  :python_file_extensions_arr

    def python_dirs_arr
      @python_dirs_arr ||= %w(src)
    end

    def extra_python_files_arr
      @extra_python_files_arr ||= []
    end

    def python_file_extensions_arr
      make_extensions_arr(@python_file_extensions_glob,
                          @python_file_extensions_arr,
                          %w(py))
    end

    def python_file_extensions_glob
      @python_file_extensions_glob || python_file_extensions_arr.join(',')
    end

    def python_files_glob
      make_files_glob(extra_python_files_arr, python_dirs_arr,
                      python_file_extensions_glob)
    end

    def python_files_arr
      exclude_garbage(@globber.glob(python_files_glob) - exclude_files_arr)
    end
  end
end
