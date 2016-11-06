#!/bin/bash

# This scrapes OSGeo mailman email list archives to count emails/month and emails/person

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

# Output files
listPostsOut="listposts.csv" # outfile counting number of posts per month for each list
emailsPerPersonOut="emailsPerPerson.csv" # outfile counting number of emails per person
emailsPerPersonPerYearOut="emailsPerPersonPerYear.csv" # outfile counting number of emails per person

declare -A posters # hash array, number of email posts per person
declare -A postersYear # hash array, number of email posts per person per year
declare -A archive # hash array, number of posts per list per month

# Write header line for output files
echo "Year-Month-List, Num Posts" > ${listPostsOut}
echo "Emailer, Total Emails" > ${emailsPerPersonOut}
echo "Year-Emailer, EmailsPerYear" > ${emailsPerPersonPerYearOut}

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
    echo dir="${dir}"
    year=`echo "${dir}" | sed -e's#-.*$##'`
    month=`echo "${dir}" | sed -e's#^.*-##' | sed -e's#/.*$##'`
    echo "${list}" >> ${listsOut}

    # Extract list of people sending emails this month
    IFS=$'\n'
    set -f
    for name in `wget -O - ${baseDir}/${list}/${dir} | grep "^<I>" | sed -e's#<I>##'` 
    do
      postersYear["$year-$name"]=$((postersYear["$year-$name"]+1))
      posters["$name"]=$((posters["$name"]+1))
      archive["$year-$month-$list"]=$((archive["$year-$month-$list"]+1))
    done

    # print out number of posts per list, per month
    for name in "${!archive[@]}"
    do
      echo "\"$name\",\"${archive[$name]}\"" >> ${listPostsOut}
    done

    # print out number of posts per poster
    for name in "${!postersYear[@]}"
    do
      echo "\"$name\",\"${postersYear[$name]}\"" >> ${emailsPerPersonPerYearOut}
    done

    # print out number of posts per poster, per year
    for name in "${!posters[@]}"
    do
      echo "\"$name\",\"${posters[$name]}\"" >> ${emailsPerPersonOut}
    done
  done
done
