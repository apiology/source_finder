# -*- coding: utf-8 -*-
require 'spec_helper'
require 'source_finder/source_file_globber'

describe SourceFinder::SourceFileGlobber do
  let_double :globber

  subject(:source_file_globber) do
    described_class.new(globber: globber)
  end

  describe '#python_dirs_arr' do
    context 'when unconfigured' do
      subject { source_file_globber.python_dirs_arr }
      it { is_expected.to eq(%w(src tests)) }
    end
    let_double :python_dirs
    context 'when configured' do
      before { source_file_globber.python_dirs_arr = python_dirs }
      subject { source_file_globber.python_dirs_arr }
      it { is_expected.to eq(python_dirs) }
    end
  end

  describe '#python_files_glob' do
    context 'with everything unconfigured' do
      expected_glob = '{{*,.*}.{py},{src,tests}/**/{*,.*}.{py}}'
      subject { source_file_globber.python_files_glob }
      it { is_expected.to eq(expected_glob) }
    end
  end

  def expect_exclude_files_found
    expect(globber).to(receive(:glob))
                   .with('**/vendor/**')
                   .and_return(['bing/vendor/buzzo.rb',
                                'bing/vendor/README.md'])
  end

  describe '#python_files_arr' do
    before do
      expect(globber)
        .to(receive(:glob))
        .with('{{*,.*}.{py},{src,tests}/**/{*,.*}.{py}}')
        .and_return(['bing/baz.py'])
      expect_exclude_files_found
    end
    subject { source_file_globber.python_files_arr }
    it { is_expected.to eq(['bing/baz.py']) }
  end

  describe '#python_file_extensions_arr' do
    subject { source_file_globber.python_file_extensions_arr }
    context 'when nothing configured' do
      it { is_expected.to eq(%w(py)) }
    end
    context 'when python_file_extensions_arr configured' do
      before { source_file_globber.python_file_extensions_arr = %w(c d) }
      it { is_expected.to eq(%w(c d)) }
    end
  end

  describe '#python_file_extensions_glob' do
    subject { source_file_globber.python_file_extensions_glob }
    context 'when nothing configured' do
      it { is_expected.to eq('py') }
    end
  end
end
