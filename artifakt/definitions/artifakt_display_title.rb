#
# Cookbook Name: artifakt
# Definition:display_title
#

define :display_title, :title => nil do

  ruby_block "display_text" do
    block do
      puts "\n\n---> #{params[:title]}\n\n"
    end
  end

end
