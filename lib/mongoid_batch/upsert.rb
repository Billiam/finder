module MongoidBatch
  module Upsert
    extend ActiveSupport::Concern

    module ClassMethods
      def bulk_upsert!(rows)
        return false unless rows.all(&:valid?)
        bulk_upsert!(rows)
      end

      def bulk_upsert!(rows)
        update, insert = rows.partition(&:persisted?)
        insert.each { |i| i.created_at ||= Time.now if i.respond_to?(:created_at=) }
        collection.insert(insert.map(&:as_document)) unless insert.empty?
        update.each(&:save)

        [update, insert]
      end
    end
  end
end

