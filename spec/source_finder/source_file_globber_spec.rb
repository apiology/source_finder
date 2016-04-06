# -*- coding: utf-8 -*-
require 'spec_helper'
require 'source_finder/source_file_globber'

describe SourceFinder::SourceFileGlobber do
  let_double :globber

  subject(:source_file_globber) do
    described_class.new(globber: globber)
  end

  describe '#source_and_doc_files_glob' do
    context 'with everything unconfigured' do
      subject(:expected_glob) do
        '{Dockerfile,Rakefile,{*,.*}.{c,clj,cljs,cpp,gemspec,html,java,js,' \
        'json,md,py,rake,rb,scala,sh,swift,yml},{app,config,db,feature,lib,' \
        'spec,src,test,tests,www}/**/{*,.*}.' \
        '{c,clj,cljs,cpp,gemspec,html,java,js,json,' \
        'md,py,rake,rb,scala,sh,swift,yml}}'
      end
      subject { source_file_globber.source_and_doc_files_glob }
      context 'called once' do
        it { is_expected.to eq(expected_glob) }
      end
      context 'called twice' do
        before do
          source_file_globber.source_and_doc_files_glob # calculate and cache
        end
        it { is_expected.to eq(expected_glob) }
      end
    end
  end
end
