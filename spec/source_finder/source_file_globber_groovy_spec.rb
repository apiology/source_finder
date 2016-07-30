# -*- coding: utf-8 -*-
require 'spec_helper'
require 'source_finder/source_file_globber'

describe SourceFinder::SourceFileGlobber do
  let_double :globber

  subject(:source_file_globber) do
    described_class.new(globber: globber)
  end

  describe '#groovy_dirs_arr' do
    context 'when unconfigured' do
      subject { source_file_globber.groovy_dirs_arr }
      it { is_expected.to eq(%w(app src var www)) }
    end
    let_double :groovy_dirs
    context 'when configured' do
      before { source_file_globber.groovy_dirs_arr = groovy_dirs }
      subject { source_file_globber.groovy_dirs_arr }
      it { is_expected.to eq(groovy_dirs) }
    end
  end

  describe '#groovy_files_glob' do
    context 'with everything unconfigured' do
      expected_glob = '{{*,.*}.{groovy},{app,src,var,www}/**/{*,.*}.{groovy}}'
      subject { source_file_globber.groovy_files_glob }
      it { is_expected.to eq(expected_glob) }
    end
  end

  def expect_exclude_files_found
    expect(globber).to(receive(:glob))
                   .with('**/vendor/**')
                   .and_return(['bing/vendor/buzzo.rb',
                                'bing/vendor/README.md'])
  end

  describe '#groovy_files_arr' do
    before do
      expect(globber).to(receive(:glob))
                     .with('{{*,.*}.{groovy},{app,src,var,www}/**/{*,.*}.' \
                           '{groovy}}')
                     .and_return(['bing/baz.groovy'])
      expect_exclude_files_found
    end
    subject { source_file_globber.groovy_files_arr }
    it { is_expected.to eq(['bing/baz.groovy']) }
  end
end
