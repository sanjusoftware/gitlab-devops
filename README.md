# Gitlab::Devops

Maintain gitlab settings (groups / projects / build vars etc) as YAML and keep it version controlled. DevOps!!
Gitlab-devops gem is a wrapper around the [gitlab](https://github.com/NARKOZ/gitlab) gem, which is an awesomely written ruby wrapper on gitlab apis. 
`gitlab-devops` uses `YAML` to define gitlab settings and apply those settings to your gitlab on one single command. This makes life easier ofcourse, as now you can do following:
 
1. Have all gitlab project settings in version control
2. Review gitlab project/group settings at one place
3. Integrate the gitlab setup in CI tool
4. Reduce the pain of going to each project to change settings via UI

## Gitlab Config file
The gem requires you to provide a config.yml (the name could be anything) which defines the settings that you want to be applied to your 
projects / groups. An example fo the config can be found [here](https://github.com/sanjusoftware/gitlab-devops/blob/master/spec/fixtures/config.yml) 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gitlab-devops'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gitlab-devops

## Usage

### CLI
Once the `gitlab-devops` gem is installed, it can be used directly from command line. e.g

```bash
gitlab-devops config.yml
```

### Existing project
If you have an existing project (CI/CD setup) in which you want to use the this gem, then you can add following lines:

```ruby
require 'gitlab/devops'

Gitlab::Devops::Config.apply(YAML.load('path-to-gitlab-config.yml'))
```

This is it!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sanjusoftware/gitlab-devops. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Gitlab::Devops project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sanjusoftware/gitlab-devops/blob/master/CODE_OF_CONDUCT.md).
