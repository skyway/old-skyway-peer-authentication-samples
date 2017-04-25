# Ruby Authentication Sample Server

## Set up

- install [ruby](https://www.ruby-lang.org/en/documentation/installation/)
- run `gem install bundler` to install required bundler
- run `bundle install --path vendor/bundle` to install required packages

## Run the server

```bash
$ bundle exec ruby sample.rb
```

You can now post to `http://localhost:8080/authentication` to generate a credential.
