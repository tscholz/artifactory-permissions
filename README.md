# Artifactory::Permissions

Some lines of code to edit users and groups in existing Artifactory permission targets
for users having "manage" permissions.

This is a WIP - by far not feature complete. ;)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'artifactory-permissions'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install artifactory-permissions

## Usage


### List permission targets accessible to your user
```ruby
api_client = Artifactory::Permissions.api_client endpoint: 'http://artifactory.local',
                                                 api_key: 'your-api-key'


Artifactory::Permissions.list api_client: api_client
# => List of permission targets (json representation) 
```

### Show / find / get permission target
```ruby
api_client = Artifactory::Permissions.api_client endpoint: 'http://artifactory.local',
                                                 api_key: 'your-api-key'


_status, permission_target = Artifactory::Permissions.find name: "<pt-name>",
                                                          api_client: api_client
# => [:ok, PermissionTarget]

_status, permission_target = Artifactory::Permissions.get "<permission-target-resource-uri>",
                                                          api_client: api_client
# => [:ok, PermissionTarget]
```

### Add / update / delete users and groups
```ruby
api_client = Artifactory::Permissions.api_client endpoint: 'http://artifactory.local',
                                                 api_key: 'your-api-key'

_status, permission_target = Artifactory::Permissions.find name: "<permission-target-name>",
                                                           api_client: api_client

user = Artifactory::Permissions.user name: "<user-name>",
                                     permissions: %w[read write],
                                     scope: "repo" #  repo, build, releaseBundle 

group = Artifactory::Permissions.group name: "<group-name>",
                                       permissions: %w[read write],
                                       scope: "repo" #  repo, build, releaseBundle 

# It does some validations on the user like presence of name, permissions etc.

_status, _permission_target, _errors =
  Artifactory::Permissions.add_user permission_target: permission_target,
                                    user: user

_status, _permission_target, _errors =
  Artifactory::Permissions.add_group permission_target: permission_target,
                                     group: group

other_user = Artifactory::Permissions.user name: "user-to-remove",
                                           permissions: %w[],
                                           scope: "repo" #  repo, build, releaseBundle 

other_group = Artifactory::Permissions.group name: "group-to-remove",
                                             permissions: %w[],
                                             scope: "repo" #  repo, build, releaseBundle  

_status, _permission_target, _errors =
  Artifactory::Permissions.delete_user permission_target: permission_target,
                                       user: user

_status, _permission_target, _errors =
  Artifactory::Permissions.delete_group permission_target: permission_target,
                                        group: group

# Finally submit it to the Artifactory

_status, _permission_target, _errors =
    Artifactory::Permissions.save permission_target: permission_target,
                                  api_client: api_client
```

You may add multiple users and groups at a time. But keep in mind Artifactory rejects the
permission target on the first error it detects. Errors might be an user or group not yet present
to the Artifactory, unknown permissions, etc.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/artifactory-permissions. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/artifactory-permissions/blob/master/CODE_OF_CONDUCT.md).


## Code of Conduct

Everyone interacting in the Artifactory::Permissions project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/artifactory-permissions/blob/master/CODE_OF_CONDUCT.md).
