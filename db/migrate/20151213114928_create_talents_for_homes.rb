class CreateTalentsForHomes < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW talents_for_home AS
        with recommended_talents as (
          select 'recommended'::text as origin, recommends.* from talents recommends
          where recommends.recommended and recommends.state = 'published' order by random() limit 3
        ),
        recents_talents as (
          select 'recents'::text as origin, recents.* from talents recents where recents.state = 'published' and ((current_timestamp - recents.created_at) <= '5 days'::interval)
          and recents.id not in(
            select recommends.id from recommended_talents recommends
          )
          order by random() limit 3
        )

        (select * from recommended_talents) union (select * from recents_talents)

    SQL
  end

  def down
    execute "DROP VIEW talents_for_home"
  end
end
