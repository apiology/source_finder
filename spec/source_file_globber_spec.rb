# -*- coding: utf-8 -*-
require 'spec_helper'
require 'source_finder/source_file_globber'

describe SourceFinder::SourceFileGlobber do
  let_double :globber

  subject(:source_file_globber) do
    SourceFinder::SourceFileGlobber.new(globber: globber)
  end

  describe '#ruby_dirs_arr' do
    context 'when unconfigured' do
      subject { source_file_globber.ruby_dirs_arr }
      it { is_expected.to eq(%w(src app config db lib test spec feature)) }
    end
    let_double :ruby_dirs
    context 'when configured' do
      before do
        source_file_globber.ruby_dirs_arr = ruby_dirs
      end
      subject { source_file_globber.ruby_dirs_arr }
      it { is_expected.to eq(ruby_dirs) }
    end
  end

  describe '#ruby_files_glob' do
    context 'with everything unconfigured' do
      expected_glob = '{Rakefile,{*,.*}.{rb,rake,gemspec},{src,app,config,' \
                      'db,lib,test,spec,feature}/**/{*,.*}.{rb,rake,gemspec}}'
      subject { source_file_globber.ruby_files_glob }
      it { is_expected.to eq(expected_glob) }
    end
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

  describe '#source_files_exclude_glob' do
    context 'with configured' do
      before do
        source_file_globber.exclude_files_arr = ['foo.txt', 'bar.txt']
      end
      subject { source_file_globber.source_files_exclude_glob }
      it { is_expected.to eq('{foo.txt, bar.txt}') }
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

  describe '#ruby_files_arr' do
    let_double :expected_ruby_files, :expected_modified_ruby_files
    before do
      expect(globber).to receive(:glob)
        .with('{Rakefile,{*,.*}.{rb,rake,gemspec},' \
              '{src,app,config,db,lib,test,spec,feature}/**/{*,.*}.' \
              '{rb,rake,gemspec}}')
        .and_return(expected_ruby_files)
      expect(expected_ruby_files).to(receive(:-).with([]))
        .and_return(expected_modified_ruby_files)
    end
    subject { source_file_globber.ruby_files_arr }
    it { is_expected.to eq(expected_modified_ruby_files) }
  end

  describe '#source_files_arr' do
    let_double :expected_source_files, :expected_modified_source_files
    before do
      expect(globber).to(receive(:glob))
        .with('{Rakefile,Dockerfile,{*,.*}.' \
              '{rb,rake,gemspec,swift,cpp,c,java,py,clj,cljs,scala,js,' \
              'yml,sh,json},{src,app,config,db,lib,test,spec,feature}/' \
              '**/{*,.*}.{rb,rake,gemspec,swift,cpp,c,java,py,clj,cljs,scala,' \
              'js,yml,sh,json}}')
        .and_return(expected_source_files)
      expect(expected_source_files).to(receive(:-).with([]))
        .and_return(expected_modified_source_files)
    end
    subject { source_file_globber.source_files_arr }
    it { is_expected.to eq(expected_modified_source_files) }
  end
end
