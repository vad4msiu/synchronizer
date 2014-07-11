class Synchronizer::LocalRecordsObserver < ActiveRecord::Observer
  observe Synchronizer.config.local_types

  def after_destroy(record)
    record = Synchronizer.config.import_class_name.constantize.find_by_local_record(record)
    record.destroy! if record
  end
end
