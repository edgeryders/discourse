module WebkitComponents
  class UserSerializer < BasicUserSerializer
    include Rails.application.routes.url_helpers

    def self.attributes_from_profile(*attrs)
      attrs.each do |attr|
        define_method attr, -> { object.user_profile.send(attr) }
      end
    end

    attributes :last_seen_at,
               :last_posted_at,
               :created_at,
               :bio_raw,
               :website,
               :location,
               :avatar_url,
               :url

    attributes_from_profile :bio_raw,
                            :website,
                            :location

    def avatar_url
      Discourse.base_url + object.avatar_template.sub('{size}', '200')
    end

    def url
      user_url(object, host: Discourse.base_url)
    end

    def include_avatar_template?
      false
    end
  end
end
