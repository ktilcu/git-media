module GitMedia
  module FilterSmudge

    def self.run!
      STDOUT.binmode
      STDIN.binmode

      can_download = false # TODO: read this from config and implement
      
      # read checksum size
      line = STDIN.read(64)
      sha = line.strip # read no more than 64 bytes
      if STDIN.eof? && GitMedia.check_ref(sha) 
        # this is a media file stub
        media_file = GitMedia.media_path_from_sharef(sha)
        if File.exists?(media_file)
          STDERR.puts('recovering media : ' + sha)
          File.open(media_file, 'r') do |f|
            while data = f.read(4096) do
              STDOUT.print data
            end
          end
        else
          # TODO: download file if not in the media buffer area
          if !can_download
            STDERR.puts('media missing, saving placeholder : ' + sha)
            STDOUT.puts line
          end
        end
      else
        # if it is not a 40 character long hash, just output
        STDERR.puts('Unknown git-media file format')
        STDOUT.print line
        while data = STDIN.read(4096)
          STDOUT.print data
        end
      end
    end

  end
end
