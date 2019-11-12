require 'deb822/emitter'

describe Deb822::Emitter do
  example 'Single paragraph' do
    buf = String.new

    emitter = Deb822::Emitter.new(buf)
    emitter.start_paragraph
      .emit_field('package', 'awesome-package')
      .emit_field('version', '0.1.0-1')
      .emit_field('description', "Awesome package\nFoo\nbar\n\nbaz\n.")

    expect(buf).to eq <<EOF
Package: awesome-package
Version: 0.1.0-1
Description: Awesome package
 Foo
 bar
 .
 baz
 ..
EOF
  end

  example 'Multiple paragraphs' do
    buf = String.new

    emitter = Deb822::Emitter.new(buf)
    emitter.start_paragraph
      .emit_field('package', 'awesome-package')
      .emit_field('version', '0.1.0-1')
    emitter.start_paragraph
      .emit_field('package', 'awesome-package')
      .emit_field('version', '0.2.0-1')

    expect(buf).to eq <<EOF
Package: awesome-package
Version: 0.1.0-1

Package: awesome-package
Version: 0.2.0-1
EOF
  end

  example 'Continuation lines' do
    buf = String.new

    emitter = Deb822::Emitter.new(buf)
    emitter.start_paragraph
      .emit_field('package', 'awesome-package')
      .emit_field('version', '0.1.0-1')
      .emit_field('description', 'Awesome package')
      .emit_continuation_line('Foo')
      .emit_continuation_line('bar')
      .emit_continuation_line('')
      .emit_continuation_line('baz')
      .emit_continuation_line('.')

    expect(buf).to eq <<EOF
Package: awesome-package
Version: 0.1.0-1
Description: Awesome package
 Foo
 bar
 .
 baz
 ..
EOF
  end
end
