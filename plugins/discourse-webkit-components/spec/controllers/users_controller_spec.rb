require "rails_helper"

path = "./plugins/discourse-webkit-components/plugin.rb"
source = File.read(path)
plugin = Plugin::Instance.new(Plugin::Metadata.parse(source), path)
plugin.activate!
plugin.initializers.first.call

describe ::WebkitComponents::UsersController do
  routes { ::WebkitComponents::Engine.routes }

  describe "index" do
    before { @users = (0...10).map { Fabricate(:user) } }

    it "returns latest users" do
      get :index, format: :json

      expect(response_json.map { |user| user['id'] }.sort).to eq @users.map(&:id)
      expect(response_json.first.keys).to_not include 'avatar_template'
      expect(response_json.first.keys).to include 'website'
      expect(response_json.first.keys).to include 'bio_raw'
    end

    it "accepts a per parameter" do
      get :index, params: { per: 5 }, format: :json

      expect(response_json.length).to eq 5
    end

    it "accepts a from parameter" do
      get :index, params: { from: 8 }, format: :json

      expect(response_json.length).to eq 2
    end
  end

  def response_json
    JSON.parse(response.body)
  end
end
