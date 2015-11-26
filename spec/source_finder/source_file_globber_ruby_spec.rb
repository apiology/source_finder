# -*- coding: utf-8 -*-
require 'spec_helper'
require 'source_finder/source_file_globber'

describe SourceFinder::SourceFileGlobber do
  let_double :globber

  subject(:source_file_globber) do
    described_class.new(globber: globber)
  end

  describe '#ruby_dirs_arr' do
    context 'when unconfigured' do
      subject { source_file_globber.ruby_dirs_arr }
      it { is_expected.to eq(%w(src app config db lib test spec feature)) }
    end
    let_double :ruby_dirs
    context 'when configured' do
      before { source_file_globber.ruby_dirs_arr = ruby_dirs }
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

  def expect_exclude_files_found
    expect(globber).to(receive(:glob))
      .with('**/vendor/**')
      .and_return(['bing/vendor/buzzo.rb', 'bing/vendor/README.md'])
  end

  describe '#ruby_files_arr' do
    before do
      expect_exclude_files_found
      expect(globber).to(receive(:glob))
        .with('{Rakefile,{*,.*}.{rb,rake,gemspec},' \
              '{src,app,config,db,lib,test,spec,feature}/**/{*,.*}.' \
              '{rb,rake,gemspec}}')
        .and_return(['bing/baz.rb'])
    end
    subject { source_file_globber.ruby_files_arr }
    it { is_expected.to eq(['bing/baz.rb']) }
  end
end
