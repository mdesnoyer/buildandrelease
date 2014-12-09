# -*- coding: utf-8 -*-
# This recipe mounts all the ephemeral devices. The first one is
# mounted to [:first_ephemeral_loc], while the ones after that are
# mounted to locations starting with
# [:neon][:filesystem][:ephemeral_base]

# First find all the drives that could be mounted
# Output of lsblk looks like:
#NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
#xvda    202:0    0  10G  0 disk 
#└─xvda1 202:1    0  10G  0 part /
#xvdb    202:16   0  30G  0 disk
# So we grab each device that isn't mounted
mountable_drives = []
`lsblk`.lines do |line|
  fields = line.split
  drive = nil
  if fields[0] =~ /xvd[b-z]/ then
    drive = fields[0]
    drive_idx = drive.bytes[3]-'b'.bytes[0]
  elsif fields[0] =~ /sd[b-z]/ then
    drive = fields[0]
    drive_idx = drive.bytes[2]-'b'.bytes[0]
  end
    
  if not drive.nil? and fields.length == 6 then
    discard_max_bytes = `cat /sys/block/#{drive}/queue/discard_max_bytes`.to_i
    trim = discard_max_bytes > 0
    
    mountable_drives << {
      :device => drive,
      :loc => drive[-1] == 'b' ? node[:neon][:filesystem][:first_ephemeral_loc] : "#{node[:neon][:filesystem][:ephemeral_base]}#{drive_idx}",
      :mkfs_options => trim ? "-E nodiscard" : nil,
      :mount_options => trim ? "-o discard" : nil,
    }
  end
end

mountable_drives.each do |drive|
  filesystem drive[:device] do
    fstype "ext4"
    device "/dev/#{drive[:device]}"
    mount drive[:loc]
    mkfs_options drive[:mkfs_options]
    options drive[:mount_options]
    action [:create, :enable, :mount]
  end
end
