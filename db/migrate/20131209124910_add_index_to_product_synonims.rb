class AddIndexToProductSynonims < ActiveRecord::Migration
  def up
    # Adds a tsvector column for the body
    add_column :spree_product_synonims, :tsv_name, :tsvector

    # Adds an index for this new column
    execute <<-SQL
    CREATE INDEX index_product_synonims_tsv_name ON spree_product_synonims USING gin(tsv_name);
    SQL

    # Updates existing rows so this new column gets calculated
    execute <<-SQL
    UPDATE spree_product_synonims SET tsv_name = (to_tsvector('english', coalesce(name, '')));
    SQL

    # Sets up a trigger to update this new column on inserts and updates
    execute <<-SQL
    CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
    ON spree_product_synonims FOR EACH ROW EXECUTE PROCEDURE
    tsvector_update_trigger(tsv_name, 'pg_catalog.english', name);
    SQL
  end

  def down
    execute("DROP TRIGGER tsvectorupdate on spree_product_synonims")
    remove_column :spree_product_synonims, :tsv_name
  end
end
