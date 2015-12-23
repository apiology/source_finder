require_relative 'langs/ruby'
require_relative 'langs/js'
require_relative 'langs/python'

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

    include RubySourceFileGlobber

    include JsSourceFileGlobber

    include PythonSourceFileGlobber

    def initialize(globber: Dir)
      @globber = globber
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

    def emacs_lockfile?(filename)
      File.basename(filename) =~ /^\.#/
    end

    def exclude_garbage(files_arr)
      files_arr.reject { |filename| emacs_lockfile?(filename) }
    end

    def source_files_arr
      exclude_garbage(@globber.glob(source_files_glob) - exclude_files_arr)
    end
  end
end
