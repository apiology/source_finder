# -*- coding: utf-8 -*-
require 'spec_helper'
require 'source_finder/source_file_globber'

describe SourceFinder::SourceFileGlobber do
  let_double :globber

  subject(:source_file_globber) do
    described_class.new(globber: globber)
  end

  describe '#source_and_doc_files_glob' do
    context 'with everything unconfigured' do
      subject(:expected_glob) do
        '{Dockerfile,Rakefile,{*,.*}.{c,clj,cljs,cpp,gemspec,html,java,js,' \
        'json,md,py,rake,rb,scala,sh,swift,yml},{app,config,db,feature,lib,' \
        'spec,src,test,www}/**/{*,.*}.{c,clj,cljs,cpp,gemspec,html,java,js,json,' \
        'md,py,rake,rb,scala,sh,swift,yml}}'
      end
      subject { source_file_globber.source_and_doc_files_glob }
      context 'called once' do
        it { is_expected.to eq(expected_glob) }
      end
      context 'called twice' do
        before do
          source_file_globber.source_and_doc_files_glob # calculate and cache
        end
        it { is_expected.to eq(expected_glob) }
      end
    end
    context 'source_file_extensions_glob configured' do
      subject(:expected_glob) do
        '{Dockerfile,Rakefile,{*,.*}.{a,b,md},{app,config,db,feature,lib,spec,src,test,www}/**/{*,.*}.{a,b,md}}'
      end
      before do
        source_file_globber.source_file_extensions_glob = 'a,b'
      end
      subject { source_file_globber.source_and_doc_files_glob }
      it { is_expected.to eq(expected_glob) }
    end
  end

  describe '#source_files_glob' do
    subject(:default_source_files_glob) do
      '{Dockerfile,Rakefile,{*,.*}.{c,clj,cljs,cpp,gemspec,html,java,js,json,' \
      'py,rake,rb,scala,sh,swift,yml},{app,config,db,feature,lib,spec,src,' \
      'test,www}/**/{*,.*}.{c,clj,cljs,cpp,gemspec,html,java,js,json,' \
      'py,rake,rb,scala,sh,swift,yml}}'
    end

    context 'with everything unconfigured' do
      subject { source_file_globber.source_files_glob }
      it { is_expected.to eq(default_source_files_glob) }
    end

    let_double :source_dirs

    context 'when everything configured' do
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
        source_file_globber.source_dirs_arr = %w(dir1 dir2)
      end
      expected_glob =
        '{AUTOEXEC.BAT,CONFIG.SYS,mumble.rb,{*,.*}.{.RB,.RAKE,JAVA,C#},' \
        '{dir1,dir2}/**/{*,.*}.{.RB,.RAKE,JAVA,C#}}'
      subject { source_file_globber.source_files_glob }
      it { is_expected.to eq(expected_glob) }
    end
  end

  SOURCE_FILE_GLOB =
    '{Dockerfile,Rakefile,{*,.*}.' \
    '{c,clj,cljs,cpp,gemspec,html,java,js,json,py,rake,rb,scala,sh,swift,' \
    'yml},{app,config,db,feature,lib,spec,src,test,www}/' \
    '**/{*,.*}.{c,clj,cljs,cpp,gemspec,html,java,js,json,py,rake,rb,scala,sh,' \
    'swift,yml}}'

  def expect_exclude_files_found
    expect(globber).to(receive(:glob))
      .with('**/vendor/**')
      .and_return(['bing/vendor/buzzo.rb', 'bing/vendor/README.md'])
  end

  describe '#source_files_arr' do
    before do
      expect_exclude_files_found
      expect(globber).to(receive(:glob))
        .with(SOURCE_FILE_GLOB)
        .and_return(['foo.md', 'bar.js', 'bing/baz.rb', 'bing/vendor/buzzo.rb'])
    end
    subject { source_file_globber.source_files_arr }
    it { is_expected.to eq(['bar.js', 'bing/baz.rb', 'foo.md']) }
  end
end
