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

For each package found in both A and B:
  1. If A and B are both `Path` dependencies
      - use the package with the more recent version
  2. If A is a `Path` dep, and B is not
      - use A's package
  3. If B is a `Path` dep and A is not
      - use B's package
  4. Repeat steps 1-3 with `Git` dependencies
  5. Repeat steps 1-3 with `Hosted` dependencies


## Known limitations

- `sdks` versions between `A` and `B` must be identical
    - if differences are detected, manually merging files is required
- If the version and dep type is the same between `A` and `B`, but there happens to be different configuration within the `Description`
    - if differences are detected, manually merging files is required