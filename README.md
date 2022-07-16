[![Dart](https://github.com/matthewnitschke/pubspec_lock_merge_driver/actions/workflows/dart.yml/badge.svg)](https://github.com/matthewnitschke/pubspec_lock_merge_driver/actions/workflows/dart.yml)
[![pub package](https://img.shields.io/pub/v/pubspec_lock_merge_driver.svg)](https://pub.dev/packages/pubspec_lock_merge_driver)

# Pubspec Lock Merge Driver

A git [merge driver](https://git-scm.com/docs/gitattributes#_defining_a_custom_merge_driver) for pubspec.lock files

# Installation

Install/activate package from pub
```
dart pub global activate pubspec_lock_merge_driver
```

Run the merge driver installation script

```sh
# install the merge driver globally (will apply to every pubspec.lock file)
pubspec_lock_merge_driver install

# install the merge driver for a local package (make sure to be at the root of the local `.git` directory)
pubspec_lock_merge_driver install --local
```

Now, when git sees conflicts within `pubspec.lock` files, it will know how to automatically resolve them based on merge strategy below

## Using a lower dart version than 2.17.5

`pubspec_lock_merge_driver` requires the dart version: `2.17.5` to run, this implies that projects utilizing the exec command `pubspec_lock_merge_driver` must also be running `2.17.5`.

There is a workaround that involves compiling an exe of the merge driver, that can be followed here:

```sh
# clone the repo to a good location
cd <some/good/location>
git clone git@github.com:matthewnitschke/pubspec_lock_merge_driver.git

# switch dart versions to the latest (asdf makes this very easy)
asdf install dart 2.17.5
asdf shell dart 2.17.5

# compile the dart script
dart compile pubspec_lock_merge_driver/bin/main.dart

# install the merge driver using the exe instead of the default executable
pubspec_lock_merge_driver install --driverCommand "<some/good/location>/pubspec_lock_merge_driver/bin/main.exe"
```

Now the merge driver should work for any dart version, and is running against a compiled executable.

# Uninstallation
You can always uninstall the merge driver using the following command

```sh
pubspec_lock_merge_driver uninstall

# or for local installs
pubspec_lock_merge_driver uninstall --local
```

# Merge strategy

Given a pubspec.lock file A, and a pubspec.lock file B:

For packages found within `A` but not `B` (and `B` but not `A`) the package will be included in the resulting pubspec.lock file

For each package found in both A and B
    - if both packages have the same description type (path, git, hosted)
    - if both packages have the same values in their description
    - chose the more recent package version, otherwise fail the entire merge

## Known limitations

- `sdks` versions between `A` and `B` must be identical
    - if differences are detected, manually merging files is required
- If the dependency has a different description type (path, git, or hosted), the entire merge will fail
- If the version and dep type is the same between `A` and `B`, but there happens to be different configuration within the `Description`
    - if differences are detected, manually merging files is required