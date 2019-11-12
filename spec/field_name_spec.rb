describe Deb822::FieldName do
  describe '#initialize' do
    it 'accepts valid names' do
      Deb822::FieldName.new('Package')
      Deb822::FieldName.new('Source')
      Deb822::FieldName.new('Standards-Version')
      Deb822::FieldName.new('Checksums-Sha256')
    end

    it 'rejects invalid names' do
      expect { Deb822::FieldName.new('') }.to raise_error(Deb822::FieldName::InvalidName)
      expect { Deb822::FieldName.new(' ') }.to raise_error(Deb822::FieldName::InvalidName)
      expect { Deb822::FieldName.new('A:') }.to raise_error(Deb822::FieldName::InvalidName)
      expect { Deb822::FieldName.new(':A') }.to raise_error(Deb822::FieldName::InvalidName)
      expect { Deb822::FieldName.new('#A') }.to raise_error(Deb822::FieldName::InvalidName)
      expect { Deb822::FieldName.new('-A') }.to raise_error(Deb822::FieldName::InvalidName)
      expect { Deb822::FieldName.new("\0") }.to raise_error(Deb822::FieldName::InvalidName)
      expect { Deb822::FieldName.new("Aあ") }.to raise_error(Deb822::FieldName::InvalidName)
    end
  end

  describe '#to_sym' do
    it 'returns canonical name' do
      expect(Deb822::FieldName.new('package').to_sym).to eq :Package
      expect(Deb822::FieldName.new('SOURCE').to_sym).to eq :Source
      expect(Deb822::FieldName.new('checksums-sha256').to_sym).to eq :'Checksums-Sha256'
    end
  end

  describe '#eql?' do
    context 'When a FieldName is given' do
      it 'returns true for the same name' do
        expect(Deb822::FieldName.new('package').eql?(Deb822::FieldName.new('Package'))).to be true
      end

      it 'returns false for a different name' do
        expect(Deb822::FieldName.new('package').eql?(Deb822::FieldName.new('source'))).to be false
      end
    end

    context 'When a String is given' do
      it 'returns true for the same name' do
        expect(Deb822::FieldName.new('package').eql?('Package')).to be true
      end

      it 'returns false for a different name' do
        expect(Deb822::FieldName.new('package').eql?('source')).to be false
      end
    end
  end
end

describe Deb822::FieldName::InvalidName do
  example { expect(described_class).to be < Deb822::Error }
end
