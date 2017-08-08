# name: discourse-edgeryders
# about: Custom discourse functionality for edgeryderse.eu
# version: 0.0.1


register_asset 'stylesheets/consent.scss'
register_asset 'stylesheets/paycoupons.scss'
register_asset 'javascripts/quiz.js'
register_asset 'javascripts/quizlib.1.0.0.min.js'


after_initialize do


  require_dependency 'user_serializer'
  class ::UserSerializer
    attributes :consent_given
    def consent_given
      object.consent_given?
    end
  end


  require_dependency 'post_serializer'
  class ::PostSerializer
    attributes :poster_paycoupons_username
    def poster_paycoupons_username
      object.user.paycoupons_username
    end
  end


  require_dependency 'topics_controller'
  module TopicsControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        before_filter :ensure_consent_given, only: [:update]
      end
    end
    module InstanceMethods
      def ensure_consent_given
        raise Discourse::InvalidAccess.new unless current_user && current_user.consent_given?
      end
    end
  end
  TopicsController.send :include, TopicsControllerPatch


  require_dependency 'posts_controller'
  module PostsControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        before_filter :ensure_consent_given, only: [:create, :update]
      end
    end
    module InstanceMethods
      def ensure_consent_given
        raise Discourse::InvalidAccess.new unless current_user && current_user.consent_given?
      end
    end
  end
  PostsController.send :include, PostsControllerPatch


  class ::User
    # NOTE: A corresponding 'edgeryders_consent' field must be created in: Admin -> Customize -> User Fields.
    def consent_given?
      UserCustomField.exists?(user_id: id, name: 'edgeryders_consent', value: '1')
    end

    def paycoupons_username
      UserCustomField.find_by(user_id: id, name: 'user_field_2').try(:value)
    end
  end


end
