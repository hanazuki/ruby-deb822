require 'deb822/scanner'

describe Deb822::Scanner do
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

    scanner = Deb822::Scanner.new(source)

    expect(scanner.next_line).to eq [:comment, " comment at beginning\n"]

    expect(scanner.next_line).to eq [:field, 'Package', 'awesome-package']
    expect(scanner.next_line).to eq [:field, 'Version', '0.1.0-1']
    expect(scanner.next_line).to eq [:field, 'Description', 'Awesome package']
    expect(scanner.next_line).to eq [:continuation, "Foo\n"]
    expect(scanner.next_line).to eq [:continuation, "bar\n"]
    expect(scanner.next_line).to eq [:continuation, "\n"]
    expect(scanner.next_line).to eq [:continuation, "baz\n"]
    expect(scanner.next_line).to eq [:continuation, ".\n"]

    expect(scanner.next_line).to eq [:paragraph_separator]
    expect(scanner.next_line).to eq [:comment, " free-standing comment\n"]

    expect(scanner.next_line).to eq [:field, 'Package', 'awesome-package']
    expect(scanner.next_line).to eq [:field, 'Version', '0.2.0-1']
    expect(scanner.next_line).to eq [:comment, " File: awsome-package.deb\n"]
    expect(scanner.next_line).to eq [:field, 'Description', 'Awesome package']
    expect(scanner.next_line).to eq [:continuation, "Foo\n"]
    expect(scanner.next_line).to eq [:comment, " comment\n"]
    expect(scanner.next_line).to eq [:continuation, "bar.\n"]
    expect(scanner.next_line).to eq [:field, 'Depends', '']

    expect(scanner.next_line).to be_nil
  end

  example 'IO input' do
    source = <<EOF
Package: awesome-package
Version: 0.1.0-1
EOF

    scanner = Deb822::Scanner.new(StringIO.new(source))

    expect(scanner.next_line).to eq [:field, 'Package', 'awesome-package']
    expect(scanner.next_line).to eq [:field, 'Version', '0.1.0-1']

    expect(scanner.next_line).to be_nil
  end
end
