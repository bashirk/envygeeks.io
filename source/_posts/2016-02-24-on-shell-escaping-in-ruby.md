---
url-id: f4e98882
id: 942ac263-0685-4c15-a894-db8affb0b59f
title: Shell Escaping in Ruby
tags: [ruby]
---

Ruby's shell escaping quality can sometimes be bad, here how to fix it.

```ruby
module Utils
  def self.escape(str)
    str = str.gsub(/(\\?[^A-Za-z0-9_\-.,:\/@\n])/) do
      if !$1.start_with?("\\")
        "\\#{$1}" else $1
      end
    end

    str.gsub(/\n/, "'\n'")
  end
end
```

```ruby
Utils.escape(Utils.escape("hello\\ world"))
# => "hello\\ world"
```
