RSpec::Matchers.define :be_bulk_upsertable_document do
  match do |doc|
    doc.class.included_modules.include?(MongoidBatch::Upsert)
  end

  description do
    desc = "be an upsertable Mongoid document"
  end
end
