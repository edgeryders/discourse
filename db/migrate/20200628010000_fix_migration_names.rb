class FixMigrationNames < ActiveRecord::Migration[5.2]


  def change
    ActiveRecord::Base.connection.execute("Delete from schema_migrations where version = '202005200100000'")
    ActiveRecord::Base.connection.execute("Delete from schema_migrations where version = '202005150200000'")
    ActiveRecord::Base.connection.execute("Delete from schema_migrations where version = '202005150100000'")
    ActiveRecord::Base.connection.execute("Delete from schema_migrations where version = '202005070100000'")
    ActiveRecord::Base.connection.execute("Delete from schema_migrations where version = '202003310200000'")
    ActiveRecord::Base.connection.execute("Delete from schema_migrations where version = '202003310000000'")
    ActiveRecord::Base.connection.execute("Delete from schema_migrations where version = '202003292129007'")
    ActiveRecord::Base.connection.execute("Delete from schema_migrations where version = '202003272129007'")
    ActiveRecord::Base.connection.execute("Delete from schema_migrations where version = '202003241210007'")


    ActiveRecord::Base.connection.execute("Insert into schema_migrations (version) values ('20200520010000')")
    ActiveRecord::Base.connection.execute("Insert into schema_migrations (version) values ('20200515020000')")
    ActiveRecord::Base.connection.execute("Insert into schema_migrations (version) values ('20200515010000')")
    ActiveRecord::Base.connection.execute("Insert into schema_migrations (version) values ('20200507010000')")
    ActiveRecord::Base.connection.execute("Insert into schema_migrations (version) values ('20200331020000')")
    ActiveRecord::Base.connection.execute("Insert into schema_migrations (version) values ('20200331000000')")
    ActiveRecord::Base.connection.execute("Insert into schema_migrations (version) values ('20200329212900')")
    ActiveRecord::Base.connection.execute("Insert into schema_migrations (version) values ('20200327212900')")
    ActiveRecord::Base.connection.execute("Insert into schema_migrations (version) values ('20200324121000')")

  end

end
