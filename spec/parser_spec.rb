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
 Foo
# comment
 bar.
Depends:
EOF

    parser = Deb822::Parser.new(source)
    paras = parser.each_paragraph.to_a

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
    expect(para1['Description']).to eq "Awesome package\nFoo\nbar.\n"
    expect(para1['Depends']).to eq ''
  end
end
