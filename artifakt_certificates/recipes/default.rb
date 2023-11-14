#
# Cookbook Name: artifakt
# Definition: artifakt_certificates
#

display_title do
    title "Update certificates"
end

# @see https://aws.amazon.com/premiumsupport/knowledge-center/ec2-expired-certificate/
bash "Update certificates" do
    user "root"
    code <<-EOH
      yum update -y ca-certificates
    EOH
end