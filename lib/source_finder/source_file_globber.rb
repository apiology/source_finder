module SourceFinder
  # Give configuration, finds source file locations by using an
  # inclusion and exclusion glob
  class SourceFileGlobber
    # See README.md for documentation on these configuration parameters.
    attr_accessor :source_dirs_arr, :extra_source_files_arr,
                  :source_file_extensions_arr, :source_files_glob,
                  :source_files_exclude_glob,
                  :source_file_extensions_glob

    attr_accessor :exclude_files_arr

    attr_accessor :ruby_dirs_arr, :extra_ruby_files_arr,
                  :ruby_file_extensions_arr

    attr_accessor :js_dirs_arr, :extra_js_files_arr,
                  :js_file_extensions_arr

    attr_accessor :python_dirs_arr, :extra_python_files_arr,
                  :python_file_extensions_arr

    def initialize(globber: Dir)
      @globber = globber
    end

    def ruby_dirs_arr
      @ruby_dirs_arr ||= %w(app config db feature lib spec src test)
    end

    def js_dirs_arr
      @js_dirs_arr ||= %w(app src www)
    end

    def python_dirs_arr
      @python_dirs_arr ||= %w(src)
    end

    def source_dirs_arr
      @source_dirs_arr ||= (ruby_dirs_arr + js_dirs_arr +
                            python_dirs_arr).sort.uniq
    end

    def extra_source_files_arr
      @extra_source_files_arr ||=
        (extra_ruby_files_arr +
         extra_js_files_arr +
         extra_python_files_arr).concat(%w(Dockerfile)).sort.uniq
    end

    def extra_ruby_files_arr
      @extra_ruby_files_arr ||= %w(Rakefile)
    end

    def extra_js_files_arr
      @extra_js_files_arr ||= []
    end

    def extra_python_files_arr
      @extra_python_files_arr ||= []
    end

    def exclude_files_arr
      if @source_files_exclude_glob
        @globber.glob(@source_files_exclude_glob)
      else
        (@exclude_files_arr || [])
      end
    end

    def source_file_extensions_arr
      @source_file_extensions_arr ||=
        (ruby_file_extensions_arr +
         js_file_extensions_arr +
         python_file_extensions_arr +
         %w(swift cpp c java py clj cljs scala yml sh json)).sort.uniq
    end

    def doc_file_extensions_arr
      @doc_file_extensions_arr ||= %w(md)
    end

    def source_file_extensions_glob
      @source_file_extensions_glob ||= source_file_extensions_arr.join(',')
    end

    def source_and_doc_file_extensions_arr
      (doc_file_extensions_arr + source_file_extensions_arr).sort.uniq
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
      glob = '{'
      if extra_source_files_arr.size > 0
        glob += "#{extra_source_files_arr.join(',')},"
      end
      glob +=
        "{*,.*}.{#{extensions_glob}}," +
        File.join("{#{dirs_arr.join(',')}}",
                  '**',
                  "{*,.*}.{#{extensions_glob}}") + '}'
      glob
    end

    def source_files_exclude_glob
      @source_files_exclude_glob || "{#{exclude_files_arr.join(', ')}}"
    end

    def js_file_extensions_arr
      @js_file_extensions_arr || %w(js)
    end

    def js_file_extensions_glob
      @js_file_extensions_glob ||= js_file_extensions_arr.join(',')
    end

    def js_files_glob
      make_files_glob(extra_js_files_arr, js_dirs_arr,
                      js_file_extensions_glob)
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

    def python_file_extensions_arr
      @python_file_extensions_arr || %w(py)
    end

    def python_file_extensions_glob
      @python_file_extensions_glob ||= python_file_extensions_arr.join(',')
    end

    def python_files_glob
      make_files_glob(extra_python_files_arr, python_dirs_arr,
                      python_file_extensions_glob)
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

    def js_files_arr
      exclude_garbage(@globber.glob(js_files_glob) - exclude_files_arr)
    end

    def python_files_arr
      exclude_garbage(@globber.glob(python_files_glob) - exclude_files_arr)
    end

    def source_files_arr
      exclude_garbage(@globber.glob(source_files_glob) - exclude_files_arr)
    end
  end
end
