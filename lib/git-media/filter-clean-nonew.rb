require 'digest/sha1'
require 'fileutils'
require 'tempfile'

module GitMedia
  module FilterCleanNoNew

    def self.run!(args)
      STDOUT.binmode
      STDIN.binmode

      #May need to transform?
      file_path = "#{args}"

      #MLF:Took out to avoid windows issues
      #sha_info = `shasum #{file_path} | awk '{print $1}'`.strip()
      #file_info = `ls -l #{file_path} | awk '{print $5}'`.strip()
      #STDERR.puts("Cleaning: #{args} : #{file_info}") #//": #{sha_info} : ")

      #This could be used to create a git-hash identifier along with the normal identifier
      #hashfunc2 = Digest::SHA1.new
      start = Time.now

      # TODO: read first 41 bytes and see if this is a stub
      #MLF: Need to do to make sure we don't mishash it (metahash it)

      line = STDIN.read(64)
      sha = line.strip # read no more than 64 bytes
      if STDIN.eof? && GitMedia.check_ref(sha)
        STDERR.puts("Got a stub #{sha} #{line.length}")

        STDOUT.write line

        #Shouldn't actually do anything
        while STDIN.read(4096)
          #STDOUT.write data
        end
      else
        hashfunc = Digest::SHA1.new

        hashfunc.update line
        while data = STDIN.read(4096)
          hashfunc.update(data)
        end


        sha_info = hashfunc.hexdigest

        blobref = GitMedia.sharef_from_shanum(sha_info)
        STDOUT.write blobref
        STDOUT.write "\n"
      end
    end
  end
end

