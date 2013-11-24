RSpec::Matchers.define :be_geospatial_document do
  match do |doc|
    doc.class.included_modules.include?(Mongoid::Geospatial)
  end

  description do
    desc = "be a geospatial Mongoid document"
  end
end
