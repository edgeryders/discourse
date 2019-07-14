require_dependency 'current_user'

class AnnotatorConstraint

  def matches?(request)
    provider = Discourse.current_user_provider.new(request.env)
    provider.current_user &&
      (provider.current_user.admin? || provider.current_user.groups.pluck(:name).map(&:downcase).include?('annotator')) &&
      custom_staff_check(request)
  rescue Discourse::InvalidAccess, Discourse::ReadOnly
    false
  end

  # Extensibility point: plugins can overwrite this to add additional checks
  # if they require.
  def custom_staff_check(request)
    true
  end

end
