# frozen_string_literal: true

require_relative 'langs/ruby'
require_relative 'langs/js'
require_relative 'langs/python'
require_relative 'langs/groovy'

module SourceFinder
  # Give configuration, finds source file locations by using an
  # inclusion and exclusion glob
  class SourceFileGlobber
    # See README.md for documentation on these configuration parameters.
    attr_writer :source_dirs_arr, :extra_source_files_arr,
                :source_file_extensions_arr, :source_files_glob,
                :source_files_exclude_glob, :exclude_files_arr

    include RubySourceFileGlobber
    include JsSourceFileGlobber
    include PythonSourceFileGlobber
    include GroovySourceFileGlobber

    def initialize(globber: Dir)
      @globber = globber
      @exclude_files_arr = nil
      @source_files_exclude_glob = nil
      @exclude_files_arr = nil
    end

    def source_dirs_arr
      @source_dirs_arr ||= (ruby_dirs_arr + js_dirs_arr +
                            python_dirs_arr + groovy_dirs_arr).sort.uniq
    end

    def extra_source_files_arr
      @extra_source_files_arr ||=
        (extra_ruby_files_arr + extra_js_files_arr +
         extra_python_files_arr + extra_groovy_files_arr)
          .concat(%w[Dockerfile]).sort.uniq
    end

    def default_source_files_exclude_glob
      '**/vendor/**'
    end

    def exclude_files_arr
      return @exclude_files_arr if @exclude_files_arr

      exclude_garbage(@globber.glob(source_files_exclude_glob))
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
      %w[swift cpp c html java py clj cljs scala yml sh json]
    end

    def source_file_extensions_arr
      @source_file_extensions_arr ||=
        exclude_garbage((ruby_file_extensions_arr +
                         js_file_extensions_arr +
                         python_file_extensions_arr +
                         groovy_file_extensions_arr +
                         default_source_file_extensions_arr))
    end

    def doc_file_extensions_arr
      @doc_file_extensions_arr ||= %w[md]
    end

    def source_file_extensions_glob
      source_file_extensions_arr.join(',')
    end

    def source_and_doc_file_extensions_arr
      exclude_garbage(doc_file_extensions_arr + source_file_extensions_arr)
    end

    def source_and_doc_file_extensions_glob
      source_and_doc_file_extensions_arr.join(',')
    end

    def source_files_glob
      glob = @source_files_glob if defined? @source_files_glob
      glob ||
        make_files_glob(extra_source_files_arr, source_dirs_arr,
                        source_file_extensions_glob)
    end

    def source_and_doc_files_glob
      make_files_glob(extra_source_files_arr, source_dirs_arr,
                      source_and_doc_file_extensions_glob)
    end

    def arr2glob(arr)
      arr.empty? ? '' : "#{arr.join(',')},"
    end

    def make_files_glob(extra_source_files_arr, dirs_arr, extensions_glob)
      # rubocop:disable Style/StringConcatenation
      '{' + arr2glob(extra_source_files_arr) + "{*,.*}.{#{extensions_glob}}," +
        File.join("{#{dirs_arr.join(',')}}", '**',
                  "{*,.*}.{#{extensions_glob}}") + '}'
      # rubocop:enable Style/StringConcatenation
    end

    def make_extensions_arr(arr_var, default_arr)
      arr_var || default_arr
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
