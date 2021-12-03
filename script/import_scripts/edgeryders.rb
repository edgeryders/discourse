# frozen_string_literal: true

require "htmlentities"
require File.expand_path(File.dirname(__FILE__) + "/base.rb")

class ImportScripts::Edgeryders < ImportScripts::Base

  BATCH_SIZE = 1000

  def initialize
    super
    @htmlentities = HTMLEntities.new
  end

  def execute
    import_users
  end

  def import_users
    puts "", "importing users"

    # user_count = mysql_query("SELECT count(uid) count FROM users").first["count"]
    #
    # last_user_id = -1
    #
    # batches(BATCH_SIZE) do |offset|
    #   users = mysql_query(<<-SQL
    #       SELECT uid,
    #              name username,
    #              mail email,
    #              created
    #         FROM users
    #        WHERE uid > #{last_user_id}
    #     ORDER BY uid
    #        LIMIT #{BATCH_SIZE}
    #   SQL
    #   ).to_a
    #
    #   break if users.empty?
    #
    #   last_user_id = users[-1]["uid"]
    #
    #   users.reject! { |u| @lookup.user_already_imported?(u["uid"]) }
    #
    #   create_users(users, total: user_count, offset: offset) do |user|
    #     email = user["email"].presence
    #     username = @htmlentities.decode(user["username"]).strip
    #     {
    #         id: user["uid"],
    #         name: username,
    #         email: email,
    #         created_at: Time.zone.at(user["created"])
    #     }
    #   end
    # end
  end


end

if __FILE__ == $0
  ImportScripts::Edgeryders.new.perform
end
