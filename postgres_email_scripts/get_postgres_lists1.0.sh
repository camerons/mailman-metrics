#/bin/sh
###############################################################################
# Download key archived postgres email lists
###############################################################################

for LIST in \
  pgsql-general \
  pgsql-admin \
  pgsql-docs \
  pgsql-novice \
  pgsql-performance \
  pgsql-sql \
  adelaide-au-pug \
  melbourne-au-pug \
  sydpug \
; do
  for YEAR in 2008 2009 2010 2011 2012 ; do
    for MONTH in 01 02 03 04 05 06 07 08 09 10 11 12 ; do
      wget "http://archives.postgresql.org/$LIST/mbox/$LIST.$YEAR-$MONTH.gz";
      gunzip "$LIST.$YEAR-$MONTH.gz";
    done
  done
done
#http://archives.postgresql.org/pgsql-general/mbox/$LIST.$YEAR-$MONTH.gz";
#http://archives.postgresql.org/pgsql-general/mbox/pgsql-general.2012-11.gz
#http://archives.postgresql.org/sydpug/mbox/sydpug.2012-10.gz
