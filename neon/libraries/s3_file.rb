#
# Author:: Christopher Peplin (<peplin@bueda.com>)
# Copyright:: Copyright (c) 2010 Bueda, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  class Provider
    class S3File < Chef::Provider::RemoteFile
      class Content < Chef::Provider::RemoteFile::Content

        private

        def grab_file_from_uri(uri)
          uri.scheme == 's3' ? fetch(uri) : super
        end

        def fetch(uri)
          require  'aws-sdk-core'
          bucket = uri.host
          key = uri.path[1..-1]
          s3 = Aws.s3(
              :region            => @new_resource.region,
              :access_key_id     => @new_resource.access_key_id,
              :secret_access_key => @new_resource.secret_access_key
          )
          Chef::Log.debug("Downloading #{key} from S3 bucket #{bucket}")
          file = Chef::FileContentManagement::Tempfile.new(@new_resource).tempfile
          begin
            s3.get_object({ bucket: bucket, key: key }, target: file)
            Chef::Log.debug("File #{key} is #{file.size} bytes on disk")
          ensure
            file.close
          end
          file
        end
      end

      def initialize(new_resource, run_context)
        super
        @content_class = Chef::Provider::S3File::Content
      end
    end
  end
end

class Chef
  class Resource
    class S3File < Chef::Resource::RemoteFile
      def initialize(name, run_context=nil)
        super
        @resource_name = :s3_file
      end

      def provider
        Chef::Provider::S3File
      end

      def region(args=nil)
        set_or_return(
          :region,
          args,
          :kind_of => String
        )
      end

      def access_key_id(args=nil)
        set_or_return(
          :access_key_id,
          args,
          :kind_of => String
        )
      end

      def secret_access_key(args=nil)
        set_or_return(
          :secret_access_key,
          args,
          :kind_of => String
        )
      end
    end
  end
end
