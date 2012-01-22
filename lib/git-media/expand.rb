# find files that are placeholders (41 char) and download them
# upload files in media buffer that are not in offsite bin
require 'git-media/status'

module GitMedia
  module Expand

    def self.run!(args)
      @push = GitMedia.get_push_transport
      @pull = GitMedia.get_pull_transport

      #puts "Fetching for #{args}"
      media_file_ref_size = GitMedia.media_ref_size2

      args.each do |file|
        file_size = File.size?(file)
        if file_size.to_i == media_file_ref_size.to_i
          sha = File.read(file).strip
          if GitMedia.check_ref(sha)
            cache_file = GitMedia.media_path_shafile(sha)
            if !File.exist?(cache_file)
              puts "No cache file #{cache_file}"
            else
              FileUtils.cp(cache_file, file)
            end
          end
        end
        #self.expand_references
        #self.upload_local_cache
      end
    end
  end
end
