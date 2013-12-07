module MongoidBatch
  module Upsert
    extend ActiveSupport::Concern

    module ClassMethods
      def bulk_upsert(rows)
        return false unless rows.all?(&:valid?)
        bulk_upsert!(rows)
      end

      def bulk_upsert!(rows)
        update, insert = rows.partition(&:persisted?)
        # Run before save and create callbacks for insertable records
        insert.each { |i| i.run_before_callbacks(:save, :create) }
        collection.insert(insert.map(&:as_document)) unless insert.empty?
        update.each(&:save)

        [update, insert]
      end
    end
  end
end

