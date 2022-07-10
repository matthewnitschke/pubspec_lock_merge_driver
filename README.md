# Pubspec Lock Merge Driver

A git [merge driver](https://git-scm.com/docs/gitattributes#_defining_a_custom_merge_driver) for pubspec.lock files

# Installation

First clone this repo to a good location
```
git clone git@github.com:matthewnitschke/pubspec_lock_merge_driver.git ~/pubspec_lock_merge_driver
```

In your `~/.gitconfig` file add the following:

```
[merge "pubspec-lock-driver"]
    name = Custom merge driver for pubspec.lock files
    driver = ~/pubspec_lock_merge_driver/pubspec-lock-merge-driver.sh %O %A %B
```

Finally in your `~/.gitattributes` file (create one if it doesn't exist). Add the following:
```
pubspec.lock merge=pubspec-lock-driver
```

Now, when git sees conflicts within `pubspec.lock` files, it will know how to automatically resolve them based on the following merge strategy

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

- `sdks` are currently only taken from `A`, and ignored on `B`
    - the current plan is to take the highest lower bound dependency version, and the highest upper bound. Not sure if that is practical yet
- If the version and dep type is the same between `A` and `B`, but there happens to be different configuration within the `Description`, `B` will be used
    - the current plan is to reject this, as it is not automatically mergeable