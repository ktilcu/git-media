require 'trollop'
require 'fileutils'
require 'git-media/transport/local'
require 'git-media/transport/s3'
require 'git-media/transport/scp'

module GitMedia

  def self.get_media_buffer
    #MLF: Modified this to be a class instance variable vs. a class variable
    @git_dir ||= `git rev-parse --git-dir`.chomp
    media_buffer = File.join(@git_dir, 'media/objects')
    FileUtils.mkdir_p(media_buffer) if !File.exist?(media_buffer)
    return media_buffer
  end

  def self.check_ref(sha_ref)
    if sha_ref.length != self.media_ref_size then
      return false
    end
    sha_file_prefix = self.sha_file_prefix
    sha_file_suffix = self.sha_file_suffix
    sha_ref.match(/^#{sha_file_prefix}[0-9a-fA-F]+#{sha_file_suffix}$/) != nil
  end

  def self.sharef_from_shanum(sha_num)
    self.sha_file_prefix+sha_num+self.sha_file_suffix
  end

  def self.sha_file_prefix
    if @sha_file_prefix == nil then
      @sha_file_prefix =  `git config git-media.sha-file-prefix`.chomp
    end
    @sha_file_prefix
  end

  def self.sha_file_suffix
    if @sha_file_suffix == nil then
      @sha_file_suffix =  `git config git-media.sha-file-suffix`.chomp
    end
    @sha_file_suffix
  end


  def self.media_ref_size
    #5+40+5
    if @media_ref_size == nil then
      @media_ref_size = 40 + self.sha_file_prefix.length + self.sha_file_suffix.length
    end
    @media_ref_size
  end

  #This is the size including the
  def self.media_ref_size2
    self.media_ref_size + 1
  end



  #The sha_num is the actual hexidecimal 'sha1' hash
  def self.media_path_from_shanum(sha_num)
    sha_ref = sharef_from_shanum(sha_num)
    self.media_path_from_sharef(sha_ref)
  end

  #A sha_ref is the identifier for the sha_file that is stored within the referencing file when 'stubbed'.
  #Their isn't much reason for this to be different from the sha_file
  def self.media_path_from_sharef(sha_ref)
    buf = self.get_media_buffer
    ref = sha_ref
    File.join(buf, ref)
  end

  #A sha_file is the filename used for the data file
  def self.media_path_shafile(sha_file)
    buf = self.get_media_buffer
    ref = sha_file
    File.join(buf, ref)
  end


  # TODO: select the proper transports based on settings
  def self.get_push_transport
    self.get_transport
  end

  def self.get_transport
    transport_type = `git config git-media.transport`.chomp
    case transport_type
      when ""
        raise "git-media.transport not set"
      when "scp"
        user = `git config git-media.scpuser`.chomp
        host = `git config git-media.scphost`.chomp
        path = `git config git-media.scppath`.chomp
        if user === ""
          raise "git-media.scpuser not set for scp transport"
        end
        if host === ""
          raise "git-media.scphost not set for scp transport"
        end
        if path === ""
          raise "git-media.scppath not set for scp transport"
        end
        GitMedia::Transport::Scp.new(user, host, path)

      when "local"
        path = `git config git-media.localpath`.chomp
        if path === ""
          raise "git-media.localpath not set for local transport"
        end
        GitMedia::Transport::Local.new(path)
      when "s3"
        bucket = `git config git-media.s3bucket`.chomp
        key = `git config git-media.s3key`.chomp
        secret = `git config git-media.s3secret`.chomp
        if bucket === ""
          raise "git-media.s3bucket not set for s3 transport"
        end
        if key === ""
          raise "git-media.s3key not set for s3 transport"
        end
        if secret === ""
          raise "git-media.s3secret not set for s3 transport"
        end
        GitMedia::Transport::S3.new(bucket, key, secret)
      else
        raise "git-media.transport #{transport_type} is unknown"
    end
  end

  def self.get_pull_transport
    self.get_transport
  end

  module Application
    def self.run!

      cmd = ARGV.shift # get the subcommand

      case cmd
        when "filter-clean" # parse delete options
          require 'git-media/filter-clean'
          GitMedia::FilterClean.run! ARGV
        when "filter-smudge"
          require 'git-media/filter-smudge'
          GitMedia::FilterSmudge.run!
        when "clear" # parse delete options
          require 'git-media/clear'
          GitMedia::Clear.run!
        when "sync"
          require 'git-media/sync'
          GitMedia::Sync.run!
        when "fetch"
          require 'git-media/fetch'
          GitMedia::Fetch.run! ARGV
        when 'status'
          require 'git-media/status'
          Trollop::options do
            opt :force, "Force status"
          end
          GitMedia::Status.run!
        else
          raise "unknown media subcommand #{cmd.inspect} -- known commands 'clear' , 'sync', 'status' "
      end

    end
  end
end
