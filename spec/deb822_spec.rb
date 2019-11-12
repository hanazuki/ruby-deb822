describe Deb822 do
  it 'has a version number' do
    expect(Deb822::VERSION).not_to be nil
  end
end

describe Deb822::Error do
  example { expect(described_class).to be < StandardError }
end
