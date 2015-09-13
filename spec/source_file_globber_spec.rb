# -*- coding: utf-8 -*-
require 'spec_helper'
require 'source_finder/source_file_globber'

describe SourceFinder::SourceFileGlobber do
  let_double :globber

  subject(:source_file_globber) do
    SourceFinder::SourceFileGlobber.new(globber: globber)
  end

  describe '#ruby_dirs' do
    subject { source_file_globber.ruby_dirs }
    # XXX: Take this file as the sample spec
    # XXX: Import spec_helper as the sample spec_helper
    context 'when unconfigured' do
      it { is_expected.to eq(%w(src app lib test spec feature)) }
    end

    let_double :ruby_dirs

    context 'when configured' do
      before do
        source_file_globber.ruby_dirs = ruby_dirs
      end
      it { is_expected.to eq(ruby_dirs) }
    end
  end

  describe '#source_files_glob' do
    subject { source_file_globber.source_files_glob }

    subject(:default_source_files_glob) do
      '{Rakefile,Dockerfile,{*,.*}.{rb,rake,gemspec,swift,cpp,c,java,py,clj,' \
      'cljs,scala,js,yml,sh,json},{src,app,lib,test,spec,feature}/**/{*,.*}.' \
      '{rb,rake,gemspec,swift,cpp,c,java,py,clj,cljs,scala,js,yml,sh,json}}'
    end

    context 'with everything unconfigured' do
      it { is_expected.to eq(default_source_files_glob) }
    end

    let_double :source_dirs

    context 'when everything configured' do
      before do
        source_file_globber.extra_ruby_files = ['mumble.rb']
        source_file_globber.extra_files =
          ['AUTOEXEC.BAT', 'CONFIG.SYS'] + source_file_globber.extra_ruby_files
        source_file_globber.ruby_file_extensions_arr =
          ['.RB', '.RAKE']
        source_file_globber.source_file_extensions_arr =
          source_file_globber.ruby_file_extensions_arr +
          ['JAVA', 'C#']
        source_file_globber.source_dirs = ['dir1', 'dir2']
      end
      subject { source_file_globber.source_files_glob }
      subject(:expected_glob) do
        '{AUTOEXEC.BAT,CONFIG.SYS,mumble.rb,{*,.*}.{.RB,.RAKE,JAVA,C#},' \
        '{dir1,dir2}/**/{*,.*}.{.RB,.RAKE,JAVA,C#}}'
      end
      it { is_expected.to eq(expected_glob) }
    end
  end
end
