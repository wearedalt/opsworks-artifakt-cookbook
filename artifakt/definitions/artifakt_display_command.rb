#
# Cookbook Name: artifakt
# Definition:display_command
#

define :display_command, :command => nil do

  ruby_block "display_text" do
    block do
      puts"\n\033[36m$ #{params[:command]}\033[39m\n\n"
    end
  end

end
