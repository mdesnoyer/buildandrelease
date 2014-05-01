
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

require 'aws-sdk'

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
    end 
  end
end

class Chef
  class Provider
    class S3File < Chef::Provider::RemoteFile
      def action_create
        Chef::Log.debug("Checking #{@new_resource} for changes")

        if current_resource_matches_target_checksum?
          Chef::Log.debug("File #{@new_resource} checksum matches target checksum (#{@new_resource.checksum}), not updating")
        else
          Chef::Log.debug("File #{@current_resource} checksum didn't match target checksum (#{@new_resource.checksum}), updating")
          fetch_from_s3(@new_resource.source) do |raw_file|
            if matches_current_checksum?(raw_file)
              Chef::Log.debug "#{@new_resource}: Target and Source checksums are the same, taking no action"
            else
              backup_new_resource
              Chef::Log.debug "copying remote file from origin #{raw_file.path} to destination #{@new_resource.path}"
              FileUtils.cp raw_file.path, @new_resource.path
              @new_resource.updated = true
            end
          end
        end
        enforce_ownership_and_permissions

        @new_resource.updated
      end

      def fetch_from_s3(source)
        reg = /s3:\/\/(?<bucket>[A-Za-z0-9_\-\.]+)\/(?<name>.+)/x
        parse = source[0].match(reg)
        if parse.nil? then
          Chef::Log.warn("Expected an S3 URL but found #{source}")
          return nil
        end
        bucket = parse['bucket']
        name = parse['name']
        s3 = AWS::S3.new
        obj = s3.buckets[bucket].objects[name]
        Chef::Log.debug("Downloading #{name} from S3 bucket #{bucket}")
        file = Tempfile.new("chef-s3-file", :mode => 'wb+')
        obj.read do |chunk|
          file.write(chunk)
        end
        Chef::Log.debug("File #{name} is #{file.size} bytes on disk")
        begin
          yield file
        ensure
          file.close
        end
      end
    end
  end
end
