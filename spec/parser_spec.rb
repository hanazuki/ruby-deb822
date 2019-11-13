require 'deb822/parser'

describe Deb822::Parser do
  example 'Multiple paragraphs' do
    source = <<EOF

# comment at beginning

Package: awesome-package
Version: 0.1.0-1
Description: Awesome package
 Foo
 bar
 .
 baz
 ..

# free-standing comment

Package: awesome-package
Version: 0.2.0-1
# File: awsome-package.deb
Description: Awesome package
 これは
# comment
 \u{1F994}．
Depends:
EOF

    parser = Deb822::Parser.new(source)
    paras = parser.paragraphs.to_a

    expect(paras.count).to eq 2

    para0 = paras[0]
    expect(para0).to be_a Deb822::Paragraph
    expect(para0.keys).to eq %w[Package Version Description]
    expect(para0['Package']).to eq 'awesome-package'
    expect(para0['Version']).to eq '0.1.0-1'
    expect(para0['Description']).to eq "Awesome package\nFoo\nbar\n\nbaz\n.\n"

    para1 = paras[1]
    expect(para1).to be_a Deb822::Paragraph
    expect(para1.keys).to eq %w[Package Version Description Depends]
    expect(para1['Package']).to eq 'awesome-package'
    expect(para1['Version']).to eq '0.2.0-1'
    expect(para1['Description']).to eq "Awesome package\nこれは\n\u{1F994}．\n"
    expect(para1['Depends']).to eq ''
  end

  example 'Empty input' do
    parser = Deb822::Parser.new('')
    expect(parser.paragraphs.to_a).to eq []
  end

  example 'Empty input with comment' do
    source = <<EOF
# comment

# comment
EOF
    parser = Deb822::Parser.new(source)
    expect(parser.paragraphs.to_a).to eq []
  end

  context 'Invalid inputs' do
    shared_examples 'raise FormatError' do
      it 'raises FormatError' do
        parser = Deb822::Parser.new(source)
        expect { parser.paragraphs.to_a }.to raise_error Deb822::FormatError
      end
    end

    context 'When a line starts with a HYPHEN-MINUS' do
      let(:source) do
<<EOF
Package: awesome-package
-Version: 0.2.1.-1
EOF
      end
      include_examples "raise FormatError"
    end

    context 'When a line contains no COLON' do
      let(:source) do
<<EOF
Package: awesome-package
Version
EOF
      end
      include_examples "raise FormatError"
    end

    context 'When a continuation line appears at the beginning of input' do
      let(:source) do
<<EOF
 aa
Package: awesome-package
Version: 0.2.1.-1
EOF
      end
      include_examples "raise FormatError"
    end

    context 'When a continuation line appears at the beginning of a paragraph' do
      let(:source) do
<<EOF
Package: awesome-package
Version: 0.1.0.-1

 aa
Package: awesome-package
Version: 0.2.1.-1
EOF
      end
      include_examples "raise FormatError"
    end

    context 'When a continuation line containing COMMA appears at the beginning of a paragraph' do
      let(:source) do
<<EOF
 Package: awesome-package
Version: 0.2.1.-1
EOF
      end
      include_examples "raise FormatError"
    end
  end
end
