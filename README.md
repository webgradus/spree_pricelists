SpreePricelists
===============

Extension for loading and updating products from XLS pricelists.

Installation
------------

Add spree_pricelists to your Gemfile:

```ruby
gem 'spree_pricelists', github: 'webgradus/spree_pricelists'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rake spree_pricelists:install:migrations
```

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

```shell
bundle
bundle exec rake test_app
bundle exec rspec spec
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_pricelists/factories'
```

Copyright (c) 2013 [name of extension creator], released under the New BSD License
