require "active_record"
require "filterable"

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)

ActiveRecord::Schema.define do
  create_table :articles, :force => true do |t|
    t.string :title
    t.string :status
    t.integer :author_id
  end

  create_table :tags, :force => true do |t|
    t.string :name
  end

  create_table :articles_tags, :force => true, :id => false do |t|
    t.integer :article_id
    t.integer :tag_id
  end
end

class Article < ActiveRecord::Base
  include Filterable::Concern

  has_and_belongs_to_many :tags

  scope :for_status, ->(status) { where(:status => status) }
  scope :for_author, ->(author_id) { where(:author_id => author_id) }

  scope :for_tag, ->(tag_ids) {
    joins(:tags).where(:tags => { :id => tag_ids }).distinct
  }
end

class Tag < ActiveRecord::Base
  has_and_belongs_to_many :articles
end

RSpec.configure do |config|
  config.around(:each) do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
