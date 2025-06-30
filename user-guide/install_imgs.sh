#!/usr/bin/env bash
SRCDIR=$1
OUTDIR=$2
DBOOKFILE=$3

if [ -z "${DBOOKFILE}" ]
then
    FILENAMES=""
    for HTMLFILE in ${OUTDIR}/*.html
    do
	echo "Scanning ${HTMLFILE}"
	THESENAMES=$(xmlstarlet sel -N xhtml=http://www.w3.org/1999/xhtml -t -v '//xhtml:img/@src' -n "${HTMLFILE}")
	FILENAMES="${FILENAMES} ${THESENAMES}"
    done
else
    FILENAMES=$(xmlstarlet sel -N db=http://docbook.org/ns/docbook -t -v '//db:imagedata/@fileref' -n "${DBOOKFILE}")
fi

for FN in ${FILENAMES}
do
    SRCFN="${SRCDIR}/${FN}"
    if [ ! -f "${SRCFN}" ]
    then
	continue
    fi
    
    DSTFN="${OUTDIR}/${FN}"
    echo "Install to ${DSTFN}"
    install -Dp -m644 "${SRCFN}" "${DSTFN}"
done
