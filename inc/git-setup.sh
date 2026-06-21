#! /bin/bash -e

mkdir -p "$VAGRANT"/git-log

git config --global init.templatedir "$FILEDIR"/git-templates

git config --global advice.detachedHead false

if test -n "$GIT_AUTHOR_NAME"
then
	git config --global user.name "$GIT_AUTHOR_NAME"
fi

if test -n "$GIT_AUTHOR_EMAIL"
then
	git config --global user.email "$GIT_AUTHOR_EMAIL"
fi

cp ~/.gitconfig ~vagrant/.gitconfig
chown vagrant ~vagrant/.gitconfig
