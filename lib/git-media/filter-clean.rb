require 'digest/sha1'
require 'fileutils'
require 'tempfile'

module GitMedia
  module FilterClean

    def self.run!(args)
      STDERR.puts("Cleaning: #{args}")
      hashfunc = Digest::SHA1.new

      #This could be used to create a git-hash identifier along with the normal identifier
      #hashfunc2 = Digest::SHA1.new
      start = Time.now

      # TODO: read first 41 bytes and see if this is a stub
      #MLF: Need to do to make sure we don't mishash it (metahash it)


      line = STDIN.read(64)
      sha = line.strip # read no more than 64 bytes
      if STDIN.eof? && GitMedia.check_ref(sha)
        #This is a stub file and the media file should already exist... this is not an additional media file

        #Unfortunately this probably already has the wrong hash, so it will look like an inbound change...
        #Or in essence, the hash of the sha_ref content and the hash of the actual content produce the same results
        STDERR.puts("Ignored cleaning of a sha_ref file #{sha}")

        STDOUT.print line

      else
        #Cleaning a normal file

        # read in buffered chunks of the data
        #  calculating the SHA and copying to a tempfile
        tempfile = Tempfile.new('media')
        hashfunc.update(line)
        tempfile.write(line)

        while data = STDIN.read(4096)
          hashfunc.update(data)
          tempfile.write(data)
        end
        tempfile.close

        # calculate and print the SHA of the data
        hx = hashfunc.hexdigest
        blobref = GitMedia.sharef_from_shanum(hx)
        STDOUT.print blobref
        STDOUT.binmode
        STDOUT.write("\n")

        # move the tempfile to our media buffer area

        media_file = GitMedia.media_path_from_shanum(hx)
        FileUtils.mv(tempfile.path, media_file)

        elapsed = Time.now - start
        STDERR.puts('Saving media : ' + hx + ' : ' + elapsed.to_s)
      end

    end
  end
end

