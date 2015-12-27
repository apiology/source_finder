# -*- coding: utf-8 -*-
require 'spec_helper'
require 'source_finder/source_file_globber'

describe SourceFinder::SourceFileGlobber do
  let_double :globber

  subject(:source_file_globber) do
    described_class.new(globber: globber)
  end

  describe '#js_dirs_arr' do
    context 'when unconfigured' do
      subject { source_file_globber.js_dirs_arr }
      it { is_expected.to eq(%w(app src www)) }
    end
    let_double :js_dirs
    context 'when configured' do
      before { source_file_globber.js_dirs_arr = js_dirs }
      subject { source_file_globber.js_dirs_arr }
      it { is_expected.to eq(js_dirs) }
    end
  end

  describe '#js_files_glob' do
    context 'with everything unconfigured' do
      expected_glob = '{{*,.*}.{js},{app,src,www}/**/{*,.*}.{js}}'
      subject { source_file_globber.js_files_glob }
      it { is_expected.to eq(expected_glob) }
    end
  end

  def expect_exclude_files_found
    expect(globber).to(receive(:glob))
      .with('**/vendor/**')
      .and_return(['bing/vendor/buzzo.rb', 'bing/vendor/README.md'])
  end

  describe '#js_files_arr' do
    before do
      expect(globber).to(receive(:glob))
        .with('{{*,.*}.{js},{app,src,www}/**/{*,.*}.{js}}')
        .and_return(['bing/baz.js'])
      expect_exclude_files_found
    end
    subject { source_file_globber.js_files_arr }
    it { is_expected.to eq(['bing/baz.js']) }
  end
end
