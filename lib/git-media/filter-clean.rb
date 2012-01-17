require 'digest/sha1'
require 'fileutils'
require 'tempfile'

module GitMedia
  module FilterClean

    def self.run!(args)
      git_root = `git rev-parse --show-toplevel`
      file_path = "#{args}"
      file_info = `ls -l #{file_path} | awk '{print $5}'`.strip()
      sha_info = `shasum #{file_path} | awk '{print $1}'`.strip()
      STDERR.puts("Cleaning: #{args} : #{file_info} : #{sha_info} : ")

      hashfunc = Digest::SHA1.new

      #This could be used to create a git-hash identifier along with the normal identifier
      #hashfunc2 = Digest::SHA1.new
      start = Time.now

      elapsed1 = start

      # TODO: read first 41 bytes and see if this is a stub
      #MLF: Need to do to make sure we don't mishash it (metahash it)

      if (file_info.to_i == GitMedia.media_ref_size)
        STDERR.puts("This could be a stub")

        line = STDIN.read(64)

        sha = line.strip # read no more than 64 bytes
        if STDIN.eof? && GitMedia.check_ref(sha)
          STDERR.puts("Ignored cleaning/annexing of a sha_ref file #{sha}")
        else
          STDERR.puts("Some strangely similar file #{sha}")
        end
        STDOUT.print line

        #Shouldn't actually do anything
        while data = STDIN.read(4096)
          STDOUT.write(data)
        end

      else
        STDERR.puts("This could/should be a media file")

        media_file = GitMedia.media_path_from_shanum(sha_info)

        if FileTest.exist?(media_file)
          #Don't need to copy anything
          STDERR.puts("File already exists: #{media_file}")
        else
          FileUtils.cp(file_path, media_file)
        end

        elapsed1 = Time.now - start
        #MLF: Just consume STDIN for cleanliness
        while STDIN.read(4096)
        end

        blobref = GitMedia.sharef_from_shanum(sha_info)
        STDOUT.print blobref
        STDOUT.binmode
        STDOUT.write("\n")

      end

      elapsed = Time.now - start
      STDERR.puts("Processed media : #{file_path} -> #{sha_info} : #{elapsed.to_s} : #{elapsed1}")

    end
  end
end

