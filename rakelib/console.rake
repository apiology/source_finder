# frozen_string_literal: true

desc 'Load up source_finder in pry'
task :console do |_t|
  exec 'pry -I lib -r source_finder'
end
