## Git workflow

Development on this project uses
[the GitHub Flow](https://guides.github.com/introduction/flow/index.html):

1. Create your feature branch (`git checkout -b my-new-feature`)
2. Stage your changes (`git add`)
3. Commit your RuboCop-compliant and test-passing changes with a
   [good commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
   (`git commit`)
4. Push to the branch (`git push -u origin my-new-feature`)
5. [Create a new Pull Request](https://bitbucket.org/nsidc/set-search-services/pull-request/new)

## Unit tests

Run the unit tests with `rake spec:unit`.

## Acceptance tests

Acceptance tests are a little trickier.  One way to run them on your local dev machine is thus:
1. Change `config/app_config.rb` and set the `development`:`solr_url` to point to the same as the `integration`:`solr_url` (it's a url on liquid for NSIDC internal use)
2. Run `rake run` to get the service running locally
3. Run `rake spec:acceptance`

Don't check these changes in though!

## RuboCop

[RuboCop](https://github.com/bbatsov/rubocop) is a style checker for Ruby, designed to enforce rules specified in the community-driven [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide). Settings are configured in `.rubocop.yml`. It can be run simply with `rubocop`.

## Guard

Guard can be used to automatically restart the puma server or run RuboCop and unit tests whenever a file changes.

* `rake guard:rubocop` - automatically re-run RuboCop
* `rake guard:specs` - automatically re-run unit tests
* `rake guard:puma` - automatically restart the puma server
* `rake guard` - automatically re-run RuboCop and the unit tests
