#!/bin/bash

SCRIPT_DIR=$(dirname "$0")

# create the git_dir if it doesnt exist (it's gitignored)
mkdir -p $SCRIPT_DIR/git_dir

# remove any lockfiles if they exist
rm $SCRIPT_DIR/git_dir/*.lock

# cleanup the existing .git folder if it exists
rm -rf $SCRIPT_DIR/git_dir/.git


pushd . > /dev/null

cd $SCRIPT_DIR/git_dir

echo
echo "----- Initializing Conflict Environment -----"
echo

git init
touch pubspec.lock && git add ./ && git commit -m "initial commit"

# Commit changes from ../branch_a.lock
git checkout -b a
cd ..
cp branch_a.lock $SCRIPT_DIR/git_dir/pubspec.lock
cd $SCRIPT_DIR/git_dir
git add pubspec.lock && git commit -m "Apply branch_a.lock from parent folder"

git checkout master

# Commit changes from ../branch_b.lock
git checkout -b b
cd ..
cp branch_b.lock $SCRIPT_DIR/git_dir/pubspec.lock
cd $SCRIPT_DIR/git_dir
git add pubspec.lock && git commit -m "Apply branch_b.lock from parent folder"

# make the conflict happen
git checkout a

echo
echo "----- Preforming Merge -----"
echo

git merge b

popd > /dev/null