#
# Cookbook Name: artifakt
# Recipe: resize-disk
#

display_title do
  title 'Current file system'
end

display_command do
  command 'lsblk'
end
run_command do
  command 'lsblk'
end

display_command do
  command 'df -h'
end
run_command do
  command 'df -h'
end

display_title do
  title 'Extending file system'
end

display_command do
  command 'sudo xfs_growfs /mnt/shared'
end
run_command do
  command 'sudo xfs_growfs /mnt/shared'
end

display_title do
  title 'Extended file system'
end

display_command do
  command 'df -h'
end
run_command do
  command 'df -h'
end
