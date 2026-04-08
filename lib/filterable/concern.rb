# A convenience module that makes filtered queries via GQL (or any interface) simple.
# Include Filterable::Concern in a model, define scopes that take an argument,
# then call MyModel.filter(filters, operator: :and/:or) where filters
# is a hash of scope names to values. Each key in the hash is sent to
# the matching scope via public_send.
#
# Example:
#   class Article < ActiveRecord::Base
#     include Filterable::Concern
#
#     scope :for_author, ->(author_id) { where(author_id: author_id) }
#     scope :for_status, ->(status) { where(status: status) }
#   end
#
#   Article.filter({ for_author: 1, for_status: "published" })
#   Article.filter({ for_author: 1, for_status: "published" }, operator: :or)

module Filterable
  module Concern
    extend ActiveSupport::Concern

    module ClassMethods
      def filter(filters, operator: :and)
        filtered_scope = where(nil)

        if filters.blank?
          return filtered_scope
        end

        filters = filters.to_h.compact

        if operator == :or
          matching_ids = filters.flat_map do |key, value|
            public_send(key, value).distinct.pluck(:id)
          end.uniq

          return where(:id => matching_ids)
        end

        if operator != :and
          raise ArgumentError, "Unsupported filter operator: #{operator.inspect}"
        end

        filters.each do |key, value|
          filtered_scope = filtered_scope.public_send(key, value)
        end

        filtered_scope
      end
    end
  end
end
