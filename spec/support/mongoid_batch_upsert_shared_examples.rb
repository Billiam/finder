shared_examples 'batch upsertable' do
  describe '.bulk_upsert' do
    specify { expect(described_class).to respond_to(:bulk_upsert) }

    context 'with invalid rows' do
      let(:row) do
        row = build_stubbed(described_class)
        row.stub(:valid?) { false }
        row
      end

      it 'is false' do
        expect(described_class.bulk_upsert([row])).to be_false
      end
    end

    context 'with new rows' do
      let(:rows) { build_list(described_class, 10) }

      it 'returns inserted records' do
        update, insert = described_class.bulk_upsert(rows)
        expect(update).to be_empty
        expect(insert).to have(10).items
      end
    end

    context 'with existing rows' do
      let(:rows) { create_list(described_class, 10) }

      it 'returns updated records' do
        update, insert = described_class.bulk_upsert(rows)
        expect(update).to have(10).items
        expect(insert).to be_empty
      end
    end

  end

  describe '.bulk_upsert!' do
    specify { expect(described_class).to respond_to(:bulk_upsert!) }
  end
end