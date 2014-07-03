# encoding: UTF-8

class Synchronizer::Base
  attr_reader :external_attrs

  def initialize(external_attrs)
    @external_attrs = external_attrs.with_indifferent_access
  end

  def sync!
    error_handler do
      if import_record.present?
        update_local_record!
      else
        create_local_record!
        create_import_record!
      end

      return true
    end
  end

  def local_record
    @local_record ||= import_record.try(:local_record)
  end

  def local_attrs
    self.class.mapping(external_attrs)
  end

  def import_record
    @import_record ||= ImportRecord.find_by_external_id_and_local_type(external_id, local_type)
  end

  def external_id
    external_attrs[config.external_id || :id]
  end

  private

  def update_local_record!
    local_record.update_attributes!(local_attrs)
  end

  def create_local_record!
    @local_record = active_record_class.create!(local_attrs)
  end

  def create_import_record!
    import_record = import_class.new(
      :local_id    => local_record.id,
      :external_id => external_id,
    )
    import_record.local_type = local_type
    import_record.save!
  end

  def notify_error(e)
    message = "Error #{self.class.name.inspect} #{e.message}\n" \
      "local_record = #{local_record.inspect}\n" \
      "local_attrs = #{@local_attrs.inspect}\n" \
      "external_attrs = #{external_attrs.inspect}\n" \
      "#{e.backtrace.join("\n")}"

    @@errors << message
    Rails.logger.error(message)
  end

  def active_record_class
    self.class.active_record_class
  end

  def import_class
    self.class.import_class
  end

  def local_type
    self.class.local_type
  end

  def error_handler &block
    ActiveRecord::Base.transaction do
      yield
    end
  rescue Exception => e
    notify_error(e)
    return false
  end

  class << self
    def sync(external_items, options = {})
      @@errors = []

      destroy_missed = options[:destroy_missed] || true
      model_sync_name = name.demodulize

      old_import_ids = options[:scope_import_record_ids] || import_records.pluck(:id)
      current_import_ids = []

      external_items.each do |item_attrs|
        sync_object = new(item_attrs)
        if sync_object.sync!
          current_import_ids << sync_object.import_record.id
        end
      end

      if destroy_missed
        delete_missing_import_records(old_import_ids, current_import_ids)
      end

      return @@errors
    end

    def delete_missing_import_records(old_ids, current_ids)
      deleted_ids = old_ids - current_ids

      import_class.find(deleted_ids).each do |import_record|
        unless import_record.destroy
          import_error_message = import_record.errors.full_messages.join('.')
          local_error_message = import_record.errors.full_messages.join('.')
          message = "Error import_error_message = #{error_message} " \
            "local_error_message = #{local_error_message} " \
            "when deleting #{import_record}"
          @@errors << message
        end
      end
    end

    def mapping(external_attrs)
      raise "Owerwrite this method for mapping external attributes to local!"
    end

    def import_records
      import_class.with_type(import_type)
    end

    def import_class
      config.import_class || ImportRecord
    end

    def local_type
      "#{active_record_class.name}"
    end

    def active_record_class
      name.demodulize.sub(/Synchronizer$/, '').constantize
    end
  end
end