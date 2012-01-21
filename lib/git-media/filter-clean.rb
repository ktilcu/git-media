require 'digest/sha1'
require 'fileutils'
require 'tempfile'

module GitMedia
  module FilterClean

    def self.run!(args)
      #May need to transform?
      file_path = "#{args}"

      #MLF:Took out to avoid windows issues
      #sha_info = `shasum #{file_path} | awk '{print $1}'`.strip()
      #file_info = `ls -l #{file_path} | awk '{print $5}'`.strip()
      #STDERR.puts("Cleaning: #{args} : #{file_info}") #//": #{sha_info} : ")

      #This could be used to create a git-hash identifier along with the normal identifier
      #hashfunc2 = Digest::SHA1.new
      start = Time.now

      elapsed1 = start

      # TODO: read first 41 bytes and see if this is a stub
      #MLF: Need to do to make sure we don't mishash it (metahash it)

      sha_info = "{unknown}"
      length = 0

      line = STDIN.read(64)
      sha = line.strip # read no more than 64 bytes
      if STDIN.eof? && GitMedia.check_ref(sha)
        STDERR.puts("Got a stub #{sha}")

        STDOUT.write line

        #Shouldn't actually do anything
        while data = STDIN.read(4096)
          STDOUT.write data
        end
      else
        STDERR.puts("This could/should be a media file")
        hashfunc = Digest::SHA1.new

        #media_file = GitMedia.media_path_from_shanum(sha_info)


        tempfile = Tempfile.new('media')
        tempfile.write line
        hashfunc.update line
        length += line.length
        while data = STDIN.read(4096)
          hashfunc.update(data)
          tempfile.write(data)
          length += line.length
        end
        tempfile.close

        elapsed1 = Time.now - start

        #if FileTest.exist?(media_file)
        #  #Don't need to copy anything
        #  STDERR.puts("File already exists: #{media_file}")
        #else
        #  FileUtils.cp(file_path, media_file)
        #end

        #MLF: Just consume STDIN for cleanliness
        #while data = STDIN.read(4096)
        #  hashfunc.update(data)
        #end

        sha_info = hashfunc.hexdigest

        blobref = GitMedia.sharef_from_shanum(sha_info)
        STDOUT.print blobref
        STDOUT.binmode
        STDOUT.write("\n")

        media_file = GitMedia.media_path_from_shanum(sha_info)

        if FileTest.exist?(media_file)
          #Don't need to copy anything
          STDERR.puts("File already exists: #{media_file}")
        else
          FileUtils.mv(tempfile.path, media_file)
        end


      end

      elapsed = Time.now - start
      STDERR.puts("Processed media : #{file_path} -> #{sha_info} : #{elapsed.to_s} : #{elapsed1} : #{length}")

    end
  end
end

