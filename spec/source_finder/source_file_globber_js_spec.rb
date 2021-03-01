# frozen_string_literal: true

require 'spec_helper'
require 'source_finder/source_file_globber'

describe SourceFinder::SourceFileGlobber do
  subject(:source_file_globber) do
    described_class.new(globber: globber)
  end

  let(:globber) { class_double(Dir, 'globber') }

  describe '#js_dirs_arr' do
    let(:js_dirs) { instance_double(Array) }

    context 'when unconfigured' do
      subject { source_file_globber.js_dirs_arr }

      it { is_expected.to eq(%w[app src www]) }
    end

    context 'when configured' do
      subject { source_file_globber.js_dirs_arr }

      before { source_file_globber.js_dirs_arr = js_dirs }

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

  def allow_exclude_files_found
    allow(globber).to(receive(:glob))
      .with('**/vendor/**')
      .and_return(['bing/vendor/buzzo.rb',
                   'bing/vendor/README.md'])
  end

  describe '#js_files_arr' do
    subject { source_file_globber.js_files_arr }

    before do
      allow(globber).to(receive(:glob))
        .with('{{*,.*}.{js},{app,src,www}/**/{*,.*}.{js}}')
        .and_return(['bing/baz.js'])
      allow_exclude_files_found
    end

    it { is_expected.to eq(['bing/baz.js']) }
  end
end
