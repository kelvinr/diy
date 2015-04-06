class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :title
      t.text :body
      t.boolean :answered, default: false

      t.integer :user_id
      t.integer :category_id
      t.column :tsv, "tsvector"

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          CREATE INDEX questions_idx ON questions USING gin(to_tsvector('english', title || ' ' || body));
          SQL
        end

        execute <<-SQL
          CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
          ON questions FOR EACH ROW EXECUTE PROCEDURE
          tsvector_update_trigger(tsv,'pg_catalog.english', title, body);
          SQL

        execute <<-SQL
          CREATE INDEX tsa_index ON questions USING gin(tsv);
          SQL
      #dir.down do
        #execute <<-SQL
        #SQL
      #end
    end
  end
end
