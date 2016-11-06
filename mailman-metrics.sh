#!/bin/bash

# This scrapes OSGeo mailman email list archives to count number of emails/month

# Copyright (c) 2016 Cameron Shorter
# Licenced under the GNU LGPL version 3.

# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LICENSE.LGPL.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".

# =============================================================================

listOfLists=https://lists.osgeo.org/mailman/listinfo
baseDir=https://lists.osgeo.org/pipermail # Base directory of email archive
#list=discuss #email list
out="listposts.csv" #outfile


echo "Date, List, Num Posts" > ${out}

# Get a list of OSGeo email lists
for list in \
  `wget -O - $listOfLists | grep "<a href=\"listinfo" \
  | sed -e's#^.*listinfo/##' \
  | sed -e's#".*$##'`
do

  # Extract URL of the month pages
  for dir in \
    `wget -O - ${baseDir}/${list}/ | grep "date.html" \
    | sed -e's#^.*href="##' \
    | sed -e's#".*$##'`
  do
    echo -n "${dir}" | sed -e's#/.*$##' >> $out # Print Year-Month
    echo -n ",${list}" >> $out
    echo -n ", "${baseDir}/${list}/${dir}", " >> $out
    # search month page and count number of posts
    wget -O - ${baseDir}/${list}/${dir} | grep "<LI><A" | wc -l >> $out
  done
done
