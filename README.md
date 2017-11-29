# leptonica-ruby-ffi
Ruby FFI interface to leptonica.

## Example of use

```ruby
#!/usr/bin/env ruby
require 'leptonica'

image = Leptonica::Pix.read('image.jpg')

image = image.resize(640, 480)

image.write('result.jpg', :jfif_jpeg)
```
