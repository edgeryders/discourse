require './spec/rails_helper'

path = "./plugins/edgeryders-permit-api-cors/plugin.rb"
plugin = Plugin::Instance.new(Plugin::Metadata.parse(File.read(path)), path)
plugin.activate!
plugin.initializers.first.call
