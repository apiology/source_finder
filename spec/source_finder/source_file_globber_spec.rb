# frozen_string_literal: true

require 'spec_helper'
require 'source_finder/source_file_globber'

describe SourceFinder::SourceFileGlobber do
  subject(:source_file_globber) do
    described_class.new(globber: globber)
  end

  let(:globber) { class_double(Dir, 'globber') }

  context 'with everything unconfigured' do
    subject { source_file_globber.source_and_doc_files_glob }

    let(:expected_glob) do
      '{Dockerfile,Rakefile,{*,.*}.' \
        '{c,clj,cljs,cpp,gemspec,groovy,html,java,js,' \
        'json,md,py,rake,rb,scala,sh,swift,yml},{app,config,db,feature,lib,' \
        'spec,src,test,tests,vars,www}/**/{*,.*}.' \
        '{c,clj,cljs,cpp,gemspec,groovy,html,java,js,json,' \
        'md,py,rake,rb,scala,sh,swift,yml}}'
    end

    context 'when called once' do
      it { is_expected.to eq(expected_glob) }
    end

    context 'when called twice' do
      before do
        source_file_globber.source_and_doc_files_glob # calculate and cache
      end

      it { is_expected.to eq(expected_glob) }
    end
  end
end
