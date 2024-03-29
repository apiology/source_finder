# frozen_string_literal: true

require 'spec_helper'
require 'source_finder/source_file_globber'

describe SourceFinder::SourceFileGlobber do
  subject(:source_file_globber) do
    described_class.new(globber: globber)
  end

  let(:globber) { class_double(Dir, 'globber') }

  describe '#source_files_glob' do
    subject(:default_source_files_glob) do
      '{Dockerfile,Rakefile,{*,.*}.' \
        '{c,clj,cljs,cpp,gemspec,groovy,html,java,js,json,' \
        'py,rake,rb,scala,sh,swift,yml},{app,config,db,feature,lib,spec,src,' \
        'test,tests,vars,www}/**/{*,.*}.' \
        '{c,clj,cljs,cpp,gemspec,groovy,html,java,js,json,' \
        'py,rake,rb,scala,sh,swift,yml}}'
    end

    let(:source_dirs) { instance_double(Array) }

    context 'with everything unconfigured' do
      subject { source_file_globber.source_files_glob }

      it { is_expected.to eq(default_source_files_glob) }
    end

    context 'when everything configured' do
      subject { source_file_globber.source_files_glob }

      before do
        source_file_globber.extra_ruby_files_arr = ['mumble.rb']
        source_file_globber.extra_source_files_arr =
          ['AUTOEXEC.BAT', 'CONFIG.SYS'] +
          source_file_globber.extra_ruby_files_arr
        source_file_globber.ruby_file_extensions_arr =
          ['.RB', '.RAKE']
        source_file_globber.source_file_extensions_arr =
          source_file_globber.ruby_file_extensions_arr +
          ['JAVA', 'C#']
        source_file_globber.source_dirs_arr = %w[dir1 dir2]
      end

      expected_glob =
        '{AUTOEXEC.BAT,CONFIG.SYS,mumble.rb,{*,.*}.{.RB,.RAKE,JAVA,C#},' \
        '{dir1,dir2}/**/{*,.*}.{.RB,.RAKE,JAVA,C#}}'

      it { is_expected.to eq(expected_glob) }
    end
  end

  def allow_exclude_files_found
    allow(globber)
      .to(receive(:glob))
      .with('**/vendor/**')
      .and_return(['bing/vendor/buzzo.rb', 'bing/vendor/README.md'])
  end

  describe '#source_files_arr' do
    subject { source_file_globber.source_files_arr }

    let(:source_file_glob) do
      '{Dockerfile,Rakefile,{*,.*}.' \
        '{c,clj,cljs,cpp,gemspec,groovy,html,java,js,json,' \
        'py,rake,rb,scala,sh,swift,' \
        'yml},{app,config,db,feature,lib,spec,src,test,tests,vars,www}/' \
        '**/{*,.*}.{c,clj,cljs,cpp,gemspec,groovy,html,java,js,json,' \
        'py,rake,rb,scala,sh,swift,yml}}'
    end

    before do
      allow_exclude_files_found
      allow(globber)
        .to(receive(:glob))
        .with(source_file_glob)
        .and_return(['foo.md', 'bar.js', 'bing/baz.rb', 'bing/vendor/buzzo.rb'])
    end

    it { is_expected.to eq(['bar.js', 'bing/baz.rb', 'foo.md']) }
  end
end
