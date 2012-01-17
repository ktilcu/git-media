# find files that are placeholders (41 char) and download them
# upload files in media buffer that are not in offsite bin
require 'git-media/status'
require 'digest/sha1'
require 'fileutils'
require 'tempfile'

module GitMedia
  module Annex

    def self.run!(args)

      @push = GitMedia.get_push_transport
      @pull = GitMedia.get_pull_transport

      args.each do |fname|
        file = File.new(fname)

        hashfunc = Digest::SHA1.new

        #This could be used to create a git-hash identifier along with the normal identifier
        #hashfunc2 = Digest::SHA1.new
        start = Time.now

        # TODO: read first 41 bytes and see if this is a stub
        #MLF: Need to do to make sure we don't mishash it (metahash it)


        line = file.read(64)
        sha = line.strip # read no more than 64 bytes
        if file.eof? && GitMedia.check_ref(sha)
          #This is a stub file and the media file should already exist... this is not an additional media file

          #Unfortunately this probably already has the wrong hash, so it will look like an inbound change...
          #Or in essence, the hash of the sha_ref content and the hash of the actual content produce the same results
          STDERR.puts("Ignored cleaning/annexing of a sha_ref file #{sha}")
        else
          #Cleaning a normal file

          hashfunc.update(line)

          while data = file.read(4096)
            hashfunc.update(data)
          end

          # calculate and print the SHA of the data
          hx = hashfunc.hexdigest
          blobref = GitMedia.sharef_from_shanum(hx)


          tempfile = Tempfile.new('blobref')
          tempfile.print blobref
          tempfile.binmode
          tempfile.write("\n")

          # move the tempfile to our media buffer area

          media_file = GitMedia.media_path_from_shanum(hx)

          file_path = file.path
          #if FileTest.exist?(media_file)
          FileUtils.mv(file_path, media_file)
          FileUtils.mv(tempfile.path, file_path)

          elapsed = Time.now - start
          STDERR.puts('Annexed file : '+fname+' : to media : ' + hx + ' : ' + elapsed.to_s)
        end

        file.close
      end
    end
  end
end
