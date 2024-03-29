describe Deb822 do
  describe '.FieldName' do
    context 'When given a String' do
      it 'returns FieldName' do
        expect(Deb822::FieldName('package')).to be_a(Deb822::FieldName).and eq 'Package'
      end
    end

    context 'When given a FieldName' do
      it 'returns the same object' do
        fn = Deb822::FieldName.new('package')
        expect(Deb822::FieldName(fn)).to be fn
      end
    end
  end
end

describe Deb822::Error do
  example { expect(described_class).to be < StandardError }
end

describe Deb822::InvalidFieldName do
  example { expect(described_class).to be < Deb822::Error }
end
