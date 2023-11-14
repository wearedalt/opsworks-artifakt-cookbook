#
# Cookbook Name: artifakt
# Definition:display_text
#

define :display_text, :text => nil do

  ruby_block "display_text" do
    block do
      puts params[:text]
    end
  end

end
