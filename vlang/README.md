# V Authentication Sample Server

## Set up

### install [V](https://vlang.io/) (0.2.4)

```
$ git clone https://github.com/vlang/v
$ cd v
$ make
$ sudo ./v symlink
```

## Run the server

```commandline
$ v run sample.v
```

You can now post to `http://localhost:8080/authenticate` to generate a credential.
