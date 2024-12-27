# simply generate all available locales

echo "generating all locales ... this may take a while"

# generated all supported locales
cp /usr/share/i18n/SUPPORTED /etc/locale.gen 

# locale-gen is slow as it builds one locale at a time
# using the localedef command
#
# to speed this up we add a local localedef script that
# basically just prints the original call with all arguments
# filter out all other locale-gen output, and pipe the
# result into GNU parallel to run as many localedef instances
# in parallel as we have CPU cores

mkdir /tmp/locales.$$
(
  cd /tmp/locales.$$
  echo 'echo; echo /usr/bin/localedef "$@"' > localedef
  chmod a+x localedef
  export PATH=.:$PATH
  export LANG=C
  export LC_ALL=C
  locale-gen | egrep "^/usr" | parallel && rm -rf /tmp/locales.$$
) 
