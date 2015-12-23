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
      expected_glob =
        '{Dockerfile,Rakefile,{*,.*}.{c,clj,cljs,cpp,gemspec,java,js,json,' \
        'md,py,rake,rb,scala,sh,swift,yml},{app,config,db,feature,lib,spec,' \
        'src,test,www}/**/{*,.*}.{c,clj,cljs,cpp,gemspec,java,js,json,md,py,' \
        'rake,rb,scala,sh,swift,yml}}'
      subject { source_file_globber.source_and_doc_files_glob }
      it { is_expected.to eq(expected_glob) }
    end
  end

  describe '#source_files_exclude_glob' do
    context 'with configured arr' do
      before { source_file_globber.exclude_files_arr = ['foo.txt', 'bar.txt'] }
      subject { source_file_globber.source_files_exclude_glob }
      it { is_expected.to eq('{foo.txt, bar.txt}') }
    end
  end

  describe '#exclude_files_arr' do
    let_double :source_arr
    context 'with configured glob' do
      before do
        source_file_globber.source_files_exclude_glob = '{*.txt}'
        expect(globber).to(receive(:glob)).with('{*.txt}')
          .and_return(source_arr)
      end
      subject { source_file_globber.exclude_files_arr }
      it { is_expected.to eq(source_arr) }
    end
  end

  describe '#source_files_glob' do
    subject(:default_source_files_glob) do
      '{Dockerfile,Rakefile,{*,.*}.{c,clj,cljs,cpp,gemspec,java,js,json,' \
      'py,rake,rb,scala,sh,swift,yml},{app,config,db,feature,lib,spec,src,' \
      'test,www}/**/{*,.*}.{c,clj,cljs,cpp,gemspec,java,js,json,' \
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
    '{c,clj,cljs,cpp,gemspec,java,js,json,py,rake,rb,scala,sh,swift,' \
    'yml},{app,config,db,feature,lib,spec,src,test,www}/' \
    '**/{*,.*}.{c,clj,cljs,cpp,gemspec,java,js,json,py,rake,rb,scala,sh,' \
    'swift,yml}}'

  describe '#source_files_arr' do
    before do
      expect(globber).to(receive(:glob))
        .with(SOURCE_FILE_GLOB)
        .and_return(['foo.md', 'bar.js', 'bing/baz.rb'])
    end
    subject { source_file_globber.source_files_arr }
    it { is_expected.to eq(['foo.md', 'bar.js', 'bing/baz.rb']) }
  end
end
