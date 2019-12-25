# frozen_string_literal: true

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

      it { is_expected.to eq(%w[app config db feature lib spec src test]) }
    end

    let_double :ruby_dirs
    context 'when configured' do
      subject { source_file_globber.ruby_dirs_arr }

      before { source_file_globber.ruby_dirs_arr = ruby_dirs }

      it { is_expected.to eq(ruby_dirs) }
    end
  end

  describe '#ruby_files_glob' do
    context 'with everything unconfigured' do
      expected_glob = '{Rakefile,{*,.*}.{gemspec,rake,rb},{app,config,' \
                      'db,feature,lib,spec,src,test}/**/{*,.*}.' \
                      '{gemspec,rake,rb}}'
      subject { source_file_globber.ruby_files_glob }

      it { is_expected.to eq(expected_glob) }
    end
  end

  def expect_exclude_files_found
    expect(globber)
      .to(receive(:glob))
      .with('**/vendor/**')
      .and_return(['bing/vendor/buzzo.rb', 'bing/vendor/README.md'])
  end

  describe '#ruby_files_arr' do
    subject { source_file_globber.ruby_files_arr }

    before do
      expect_exclude_files_found
      expect(globber).to receive(:glob)
        .with('{Rakefile,{*,.*}.{gemspec,rake,rb},' \
              '{app,config,db,feature,lib,spec,src,test}/**/{*,.*}.' \
              '{gemspec,rake,rb}}')
        .and_return(['bing/baz.rb'])
    end

    it { is_expected.to eq(['bing/baz.rb']) }
  end

  describe '#ruby_file_extensions_arr' do
    subject { source_file_globber.ruby_file_extensions_arr }

    context 'when nothing configured' do
      it { is_expected.to eq(%w[gemspec rake rb]) }
    end

    context 'when ruby_file_extensions_arr configured' do
      before { source_file_globber.ruby_file_extensions_arr = %w[c d] }

      it { is_expected.to eq(%w[c d]) }
    end
  end
end
