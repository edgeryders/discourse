require "rails_helper"

path = "./plugins/discourse-webkit-components/plugin.rb"
source = File.read(path)
plugin = Plugin::Instance.new(Plugin::Metadata.parse(source), path)
plugin.activate!
plugin.initializers.first.call

describe ::WebkitComponents::TopicsController do
  routes { ::WebkitComponents::Engine.routes }

  describe "index" do
    fab!(:event) { Fabricate(:topic) }
    fab!(:story) { Fabricate(:topic) }
    fab!(:organizer) { Fabricate(:topic) }
    fab!(:festival_category) { Fabricate(:category, slug: :festival) }
    fab!(:conversation_category) { Fabricate(:category, slug: :conversation) }
    fab!(:organizer_category) { Fabricate(:category, slug: :organizers) }
    fab!(:event_tag) { Fabricate(:tag, name: "webcontent-event") }
    fab!(:story_tag) { Fabricate(:tag, name: "webcontent-story") }
    fab!(:confirmed_tag) { Fabricate(:tag, name: "event-confirmed") }

    before do
      event.tags << event_tag
      story.tags << story_tag

      event.update(category: festival_category)
      story.update(category: conversation_category)
      organizer.update(category: organizer_category)
    end

    it "returns a topic for a single tag" do
      get :index, params: { tags: story_tag.name }, format: :json

      expect(response_json.map { |topic| topic['id'] }).to include story.id
    end

    it "returns a topic for multiple tags" do
      get :index, params: { tags: [event_tag.name, story_tag.name].join(',') }, format: :json

      expect(response_json.map { |topic| topic['id'] }).to include story.id
      expect(response_json.map { |topic| topic['id'] }).to include event.id
    end

    it "returns a topic for a single category" do
      get :index, params: { categories: festival_category.slug }, format: :json

      expect(response_json.map { |topic| topic['id'] }).to include event.id
      expect(response_json.map { |topic| topic['id'] }).to_not include story.id
    end

    it "returns a topic for multiple categories" do
      get :index, params: { categories: [festival_category.slug, conversation_category.slug].join(',') }, format: :json

      expect(response_json.map { |topic| topic['id'] }).to include event.id
      expect(response_json.map { |topic| topic['id'] }).to include story.id
    end

    it "can accept a serializer argument" do
      event.tags << confirmed_tag
      get :index, params: { tags: event_tag.name, serializer: "event" }, format: :json

      event_json = response_json[0]
      expect(event_json['confirmed']).to eq true
      expect(event_json['tags'].length).to eq event.tags.length
      expect(event_json)
    end

    it "return the full topic body for organizers" do
      organizer.posts << Fabricate(:post)
      get :index, params: { serializer: "organizer" }, format: :json

      expect(response_json.detect { |t| t['id'] == organizer.id }['cooked']).to eq organizer.first_post.cooked
    end

    it "returns the full topic body for events" do
      event.posts << Fabricate(:post)
      get :index, params: { serializer: "event" }, format: :json

      expect(response_json.detect { |t| t['id'] == event.id }['cooked']).to eq event.first_post.cooked
    end

    it "uses the default serializer if an unknown serializer is passed" do
      get :index, params: { serializer: "wark" }, format: :json

      expect(response_json.map { |topic| topic['id'] }).to include story.id
      expect(response_json.map { |topic| topic['id'] }).to include event.id
    end
  end

  def response_json
    JSON.parse(response.body)
  end
end
