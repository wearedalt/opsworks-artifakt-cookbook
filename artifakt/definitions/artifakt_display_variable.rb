
#
# Cookbook Name: artifakt
# Definition:display_variable
#

$artifakt_redacted_vars = %w[S3_SECRET MYSQL_PASSWORD ARTIFAKT_MYSQL_PASSWORD AWS_ES_PASSWORD]

define :display_variable, :key => nil, :value => nil do

  ruby_block "display_variable" do
    block do
      if ($artifakt_redacted_vars.include?(:key))
        puts params[:key]+"=[REDACTED]"
      else
        if (params[:value])
          puts params[:key]+"="+params[:value]
        end
      end
    end
  end

end

