#!/bin/sh -e
#
# builds an RPM from the current directory contents
# the spec file is copied to the SPECS directory, and the rest to SOURCES
# Source0 in the spec file is usually a URL, and automatically downloaded
#
# 2014.12.14 darell tan
#

RPM_SRC_DIR=`rpm -E "%{_sourcedir}"`
RPM_SPEC_DIR=`rpm -E "%{_specdir}"`

# create rpmbuild directories, if they don't exist
[ ! -d "$RPM_SRC_DIR" ] && mkdir -p "$RPM_SRC_DIR"
[ ! -d "$RPM_SPEC_DIR" ] && mkdir -p "$RPM_SPEC_DIR"

# hack to evaluate a spec file
# see http://stackoverflow.com/q/3634650
eval_spec() {
	type rpmbuild >/dev/null 2>&1 || { echo >&2 "rpmbuild not found"; exit 1; }
	SPEC_EVAL=`mktemp /tmp/rpm-eval.XXXXXXXXXX`
	cat "$1" | sed '/^%prep/,$d' > "$SPEC_EVAL"
	echo -e '%prep\ncat<<__EOF__' >> "$SPEC_EVAL"
	cat "$1" | sed '/^%prep/,$d' | grep '^[^#]\+:' >> "$SPEC_EVAL"
	echo '__EOF__' >> "$SPEC_EVAL"
	rpmbuild -bp "$SPEC_EVAL" 2>/dev/null 
	rm -f "$SPEC_EVAL"
}

# download source
SPEC_URL=`eval_spec minidlna.spec | sed -n 's/Source0:[ \t]*// p'`
SRC_FILE=${SPEC_URL##*/}
[ ! -f "$SRC_FILE" ] && curl -L -O "$SPEC_URL"

SPECFILE=
for f in *; do
	[ "$f" = `basename $0` ] && continue
	if [ "x${f##*.}" == "xspec" ]; then
		SPECFILE=$RPM_SPEC_DIR/$f
		cp -u "$f" "$RPM_SPEC_DIR"
	else
		cp -u "$f" "$RPM_SRC_DIR"
	fi
done

if [ ! -f "$SPECFILE" ]; then
	echo "copying failed. can't find spec file $SPECFILE"
	exit 1
fi

echo "building RPM..."
rpmbuild -ba "$SPECFILE"

