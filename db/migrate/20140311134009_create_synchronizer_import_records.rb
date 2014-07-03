# encoding: UTF-8

class CreateSynchronizerImportRecords < ActiveRecord::Migration
  def change
    create_table "synchronizer_import_records", :force => true do |t|
      t.string   "local_type", :null => false
      t.integer  "local_id",   :null => false
      t.string   "external_id",  :null => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "synchronizer_import_records", ["external_id"], :name => "index_synchronizer_import_records_on_external_id"
    add_index "synchronizer_import_records", ["external_id", "local_type"], :name => "index_synchronizer_import_records_on_external_id_and_local_type"
    add_index "synchronizer_import_records", ["local_id", "local_type"], :name => "index_synchronizer_import_records_on_local_id_and_local_type"
    add_index "synchronizer_import_records", ["local_type"], :name => "index_synchronizer_import_records_on_local_type"
  end
end
