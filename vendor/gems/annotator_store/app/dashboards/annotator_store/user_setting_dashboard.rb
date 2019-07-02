require "administrate/base_dashboard"

module AnnotatorStore
  class UserSettingDashboard < Administrate::BaseDashboard

    # ATTRIBUTE_TYPES
    # a hash that describes the type of each of the model's fields.
    #
    # Each different type represents an Administrate::Field object,
    # which determines how the attribute is displayed
    # on pages throughout the dashboard.
    ATTRIBUTE_TYPES = {
      discourse_user: Field::BelongsTo.with_options(class_name: '::User'),
      language: Field::BelongsTo.with_options(class_name: 'AnnotatorStore::Language'),
      id: Field::Number,
    }.freeze

    # COLLECTION_ATTRIBUTES
    # an array of attributes that will be displayed on the model's index page.
    #
    # By default, it's limited to four items to reduce clutter on index pages.
    # Feel free to add, remove, or rearrange items.
    COLLECTION_ATTRIBUTES = [
      #:id,
      :discourse_user,
      :language,
    ].freeze

    # SHOW_PAGE_ATTRIBUTES
    # an array of attributes that will be displayed on the model's show page.
    SHOW_PAGE_ATTRIBUTES = [
      :discourse_user,
      :language,
      :id,
    ].freeze

    # FORM_ATTRIBUTES
    # an array of attributes that will be displayed
    # on the model's form (`new` and `edit`) pages.
    FORM_ATTRIBUTES = [
      :discourse_user,
      :language,
    ].freeze

    # Overwrite this method to customize how tag names are displayed
    # across all pages of the admin dashboard.
    #
    def display_resource(tag_name)
      "User Settings"
    end

  end
end
