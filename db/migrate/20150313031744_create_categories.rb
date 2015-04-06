class CreateCategories < ActiveRecord::Migration
  def change
   create_table :categories do |t|
     t.string :name
     t.text :description
     t.column :tsv, "tsvector"

     t.timestamps
   end

   reversible do |dir|
     dir.up do
       execute <<-SQL
         CREATE INDEX categories_idx ON categories USING gin(to_tsvector('english', name || ' ' || description));
         SQL
       end

       execute <<-SQL
         CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
         ON categories FOR EACH ROW EXECUTE PROCEDURE
         tsvector_update_trigger(tsv,'pg_catalog.english', name, description);
         SQL

       execute <<-SQL
         CREATE INDEX tsv_index ON categories USING gin(tsv);
         SQL
     #dir.down do
       #execute <<-SQL
       #SQL
     #end
   end
  end
end
