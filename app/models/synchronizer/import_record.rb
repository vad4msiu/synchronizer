class Synchronizer::ImportRecord < ActiveRecord::Base
  belongs_to(:local_record,
    :polymorphic  => true,
    :foreign_key  => :local_id,
    :foreign_type => :local_type,
    :dependent    => :destroy
  )

  Synchronizer.config.local_types.each do |type|
    scope "only_#{type.underscore}", -> { where(:local_type => type) }
  end
  scope :with_type, ->(type) { where(:local_type => type.to_s) }
  scope :with_external_ids, ->(ids) { where(:external_id => ids) }
  scope :with_local_ids, ->(ids) { where(:local_id => ids) }

  validates :local_type, :inclusion => { :in => ->(o) { Synchronizer.config.local_types }}
  validates :local_record, :presence => true

  def self.find_by_external_id!(external_id)
    find_by!(:external_id => external_id)
  end

  def self.find_by_local_record(local_record)
    find_by(:local_record => local_record)
  end

  def self.find_by_external_id_and_local_type(external_id, local_type)
    find_by(:external_id => external_id, :local_type => local_type)
  end

  def self.find_by_local_id_and_local_type(local_id, local_type)
    find_by(:local_id => local_id, :local_type => local_type)
  end
end