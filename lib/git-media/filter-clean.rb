require 'digest/sha1'
require 'fileutils'
require 'tempfile'

module GitMedia
  module FilterClean

    def self.run!
      # determine and initialize our media buffer directory
      media_buffer = GitMedia.get_media_buffer

      hashfunc = Digest::SHA1.new
      hashfunc2 = Digest::SHA1.new
      start = Time.now

      # TODO: read first 41 bytes and see if this is a stub
      #MLF: Need to do to make sure we don't mishash it (metahash it)
      
            

      # read in buffered chunks of the data
      #  calculating the SHA and copying to a tempfile
      tempfile = Tempfile.new('media')
      while data = STDIN.read(4096)
        hashfunc.update(data)
        tempfile.write(data)
      end
      tempfile.close

      # calculate and print the SHA of the data
      hx = hashfunc.hexdigest
      blobref = GitMedia.media_ref(hx)
      STDOUT.print blobref
      STDOUT.binmode
      STDOUT.write("\n")

      # move the tempfile to our media buffer area
      media_file = GitMedia.media_path_shanum(hx) 
#File.join(media_buffer, "sha1_"+hx+".blob")
      FileUtils.mv(tempfile.path, media_file)

      elapsed = Time.now - start
      STDERR.puts('Saving media : ' + hx + ' : ' + elapsed.to_s)
    end

  end
end
