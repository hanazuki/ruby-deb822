describe Deb822::Paragraph do
  describe '#initialize' do
    it 'accepts initial value' do
      init = {
        'Package' => 'awesome-package',
        'Version' => '0.1.0-1',
      }

      para = Deb822::Paragraph.new(init)

      expect(para.size).to eq 2
      expect(para.keys).to eq [Deb822::FieldName.new('Package'), Deb822::FieldName.new('Version')]
      expect(para['package']).to eq 'awesome-package'

      para['architecture'] = 'all'
      expect(para.keys).to eq [Deb822::FieldName.new('Package'), Deb822::FieldName.new('Version'),
                               Deb822::FieldName.new('Architecture')]
    end
  end
end
