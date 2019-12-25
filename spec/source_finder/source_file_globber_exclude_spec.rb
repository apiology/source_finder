# frozen_string_literal: true

require 'spec_helper'
require 'source_finder/source_file_globber'

describe SourceFinder::SourceFileGlobber do
  subject(:source_file_globber) do
    described_class.new(globber: globber)
  end

  let(:globber) { class_double(Dir, 'globber') }

  describe '#source_files_exclude_glob' do
    context 'with configured arr' do
      subject { source_file_globber.source_files_exclude_glob }

      before { source_file_globber.exclude_files_arr = ['foo.txt', 'bar.txt'] }

      it { is_expected.to eq('{foo.txt,bar.txt}') }
    end

    context 'with configured glob' do
      subject { source_file_globber.source_files_exclude_glob }

      before { source_file_globber.source_files_exclude_glob = '**/mumble/**' }

      it { is_expected.to eq('**/mumble/**') }
    end

    context 'with nothing configured' do
      subject { source_file_globber.source_files_exclude_glob }

      it { is_expected.to eq('**/vendor/**') }
    end
  end

  describe '#exclude_files_arr' do
    subject(:source_arr) { %w[file1 file2] }

    context 'with configured glob' do
      subject { source_file_globber.exclude_files_arr }

      before do
        source_file_globber.source_files_exclude_glob = '{*.txt}'
        allow(globber).to(receive(:glob)).with('{*.txt}')
                      .and_return(source_arr)
      end

      it { is_expected.to eq(source_arr) }
    end
  end
end
