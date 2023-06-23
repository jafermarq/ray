# Building manylinux2014 wheels

**WARNING:** To cause everything to be rebuilt, this script will delete ALL changes to the
repository, including both changes to tracked files, and ANY untracked files.

It will also cause all files inside the repository to be owned by root, and
produce .whl files owned by root.

Inside the root directory (i.e., one level above this python directory), run

```
# the tag `2022-05-14-b55b680` was the one around the time Ray 1.11.1 was released
docker run -e TRAVIS_COMMIT=<commit_number_to_use> --rm -w /ray -v `pwd`:/ray -ti quay.io/pypa/manylinux2014_x86_64:2022-05-14-b55b680  /ray/python/build-wheel-manylinux2014.sh
```

The wheel files will be placed in the .whl directory.

## Building MacOS wheels

To build wheels for MacOS, run the following inside the root directory (i.e.,
one level above this python directory).

```
./python/build-wheel-macos.sh
```

The script uses `sudo` multiple times, so you may need to type in a password.
