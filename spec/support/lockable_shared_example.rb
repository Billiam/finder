shared_examples 'lockable' do
  describe '.lock_with' do
    expect(described_class).to respond_to(:lock_with)
  end
end