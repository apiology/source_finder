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
                  :source_files_exclude_glob, :source_file_extensions_glob,
                  :exclude_files_arr

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
        (extra_ruby_files_arr + extra_js_files_arr + extra_python_files_arr)
        .concat(%w(Dockerfile)).sort.uniq
    end

    def default_source_files_exclude_glob
      '**/vendor/**'
    end

    def exclude_files_arr
      if @exclude_files_arr
        @exclude_files_arr
      elsif @source_files_exclude_glob
        exclude_garbage(@globber.glob(@source_files_exclude_glob))
      else
        exclude_garbage(@globber.glob(default_source_files_exclude_glob))
      end
    end

    def source_files_exclude_glob
      if @exclude_files_arr
        "{#{exclude_files_arr.join(',')}}"
      elsif @source_files_exclude_glob
        @source_files_exclude_glob
      else
        default_source_files_exclude_glob
      end
    end

    def default_source_file_extensions_arr
      %w(swift cpp c html java py clj cljs scala yml sh json)
    end

    def source_file_extensions_arr
      @source_file_extensions_arr ||=
        exclude_garbage((ruby_file_extensions_arr +
                         js_file_extensions_arr +
                         python_file_extensions_arr +
                         default_source_file_extensions_arr))
    end

    def doc_file_extensions_arr
      @doc_file_extensions_arr ||= %w(md)
    end

    def source_file_extensions_glob
      @source_file_extensions_glob ||= source_file_extensions_arr.join(',')
    end

    def source_and_doc_file_extensions_arr
      exclude_garbage(doc_file_extensions_arr + source_file_extensions_arr)
    end

    def source_and_doc_file_extensions_glob
      if @source_and_doc_file_extensions_glob
        @source_and_doc_file_extensions_glob
      elsif @source_file_extensions_glob
        @source_and_doc_file_extensions_glob ||=
          @source_file_extensions_glob + ',' + doc_file_extensions_arr.join(',')
      else
        @source_and_doc_file_extensions_glob ||=
          source_and_doc_file_extensions_arr.join(',')
      end
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

    def arr2glob(arr)
      arr.size > 0 ? "#{arr.join(',')}," : ''
    end

    def make_files_glob(extra_source_files_arr,
                        dirs_arr,
                        extensions_glob)
      '{' + arr2glob(extra_source_files_arr) + "{*,.*}.{#{extensions_glob}}," +
        File.join("{#{dirs_arr.join(',')}}", '**',
                  "{*,.*}.{#{extensions_glob}}") + '}'
    end

    def emacs_lockfile?(filename)
      File.basename(filename) =~ /^\.#/
    end

    def exclude_garbage(files_arr)
      files_arr.reject { |filename| emacs_lockfile?(filename) }.sort.uniq
    end

    def source_files_arr
      exclude_garbage(@globber.glob(source_files_glob) - exclude_files_arr)
    end
  end
end
