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
        '{Rakefile,Dockerfile,{*,.*}.{md,rb,rake,gemspec,swift,cpp,c,java,' \
        'py,clj,cljs,scala,js,yml,sh,json},{src,app,config,db,lib,test,' \
        'spec,feature}/**/{*,.*}.{md,rb,rake,gemspec,swift,cpp,c,java,' \
        'py,clj,cljs,scala,js,yml,sh,json}}'
      subject { source_file_globber.source_and_doc_files_glob }
      it { is_expected.to eq(expected_glob) }
    end
  end

  describe '#source_files_glob' do
    subject(:default_source_files_glob) do
      '{Rakefile,Dockerfile,{*,.*}.{rb,rake,gemspec,swift,cpp,c,java,py,clj,' \
      'cljs,scala,js,yml,sh,json},{src,app,config,db,lib,test,spec,feature}' \
      '/**/{*,.*}.{rb,rake,gemspec,swift,cpp,c,java,py,clj,cljs,scala,js,' \
      'yml,sh,json}}'
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
    '{Rakefile,Dockerfile,{*,.*}.' \
    '{rb,rake,gemspec,swift,cpp,c,java,py,clj,cljs,scala,js,' \
    'yml,sh,json},{src,app,config,db,lib,test,spec,feature}/' \
    '**/{*,.*}.{rb,rake,gemspec,swift,cpp,c,java,py,clj,cljs,scala,' \
    'js,yml,sh,json}}'

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
    it { is_expected.to eq(['foo.md', 'bar.js', 'bing/baz.rb']) }
  end
end
