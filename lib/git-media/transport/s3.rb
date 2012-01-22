require 'git-media/transport'
#require 'right_aws'
require "aws/s3"

# git-media.transport s3
# git-media.s3bucket
# git-media.s3key
# git-media.s3secret

module GitMedia
  module Transport
    class S3 < Base

      def initialize(bucket_name, access_key_id = nil, secret_access_key = nil)
        AWS::S3::Base.establish_connection!(
                :access_key_id => access_key_id,
                :secret_access_key => secret_access_key
        )

        #@s3 = RightAws::S3Interface.new(access_key_id, secret_access_key,
        #      {:multi_thread => true}) #, :logger => Logger.new('/tmp/s3.log')})
        @bucket_name = bucket_name
        @bucket_path = "test2/"
        @bucket = AWS::S3::Bucket.find bucket_name # bu@s3.list_all_my_buckets.map { |a| a[:name] }
        if !@bucket
          puts "Creating New Bucket #{bucket_name}"
          AWS::S3::Bucket.create bucket_name
          @bucket = AWS::S3::Bucket.find bucket_name # bu@s3.list_all_my_buckets.map { |a| a[:name] }
        end
      end

      #def read?
      #  @buckets.size > 0
      #end
      #
      def get_file(sha, to_file)
        if @bucket["#{@bucket_path}#{sha}"]
          open(to_file, 'w') do |file|
            file.binmode
            AWS::S3::S3Object.stream("#{@bucket_path}#{sha}", @bucket_name) do |chunk|
              file.write chunk
            end
          end
        else
          puts "No remote file: #{@bucket_path}#{sha}"
        end

        #to = File.new(to_file, File::CREAT|File::RDWR)
        #@s3.get(@bucket, sha) do |chunk|
        #  to.write(chunk)
        #end
        #to.close

      end

      #def write?
      #  @buckets.size > 0
      #end
      #
      def put_file(sha, from_file)
        #S3Object.value 'headshot.jpg', 'photos'
        AWS::S3::S3Object.store("#{@bucket_path}#{sha}", open(from_file), @bucket_name)
      end

      def get_unpushed(files)
        #bucket_files = @bucket.objects
        puts @bucket
        #keys = @s3.list_bucket(@bucket).map { |f| f[:key] }
        files.select do |f|
          !@bucket["#{@bucket_path}#{f}"] #.include?(f)
        end
      end

    end
  end
end
