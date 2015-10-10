# RackPassword
![](http://img.shields.io/gem/v/rack_password.svg?style=flat-square)
[![](http://img.shields.io/codeclimate/github/netguru/rack_password.svg?style=flat-square)](https://codeclimate.com/github/netguru/rack_password)
[![](http://img.shields.io/travis/netguru/rack_password.svg?style=flat-square)](ps://travis-ci.org/netguru/rack_password)

Small rack middleware to block your site from unwanted vistors. A little bit more convenient than basic auth - browser will ask you once for the password and then set a cookie to remember you - unlike the http basic auth it wont prompt you all the time.

## Installation

Add this line to your application's Gemfile:

    gem 'rack_password'

## Usage

Let's assume you want to password protect your staging environemnt. Add something like this to `config/environments/staging.rb `


```
config.middleware.use RackPassword::Block, auth_codes: ['janusz']
```

From now on, your staging app should prompt for `janusz` password before you access it.

You can also generate time based access tokens. Visit `your-rack-protected-site.com/?code=janusz`.
Your token will be generated and query string that should be appended to the url will be displayed:

```
?token=5959dd0c8481a19b4c0d0955cabc215f465cf1182923f90e00751daa0f38a0a4&valid_until=2015-10-11+00:45:00
```

## Contributing

1. Fork it ( https://github.com/netguru/rack_password/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
