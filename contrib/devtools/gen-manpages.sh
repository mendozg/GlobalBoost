#!/bin/sh

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

GLOBALBOOSTD=${GLOBALBOOSTD:-$SRCDIR/globalboostd}
GLOBALBOOSTCLI=${GLOBALBOOSTCLI:-$SRCDIR/globalboost-cli}
GLOBALBOOSTTX=${GLOBALBOOSTTX:-$SRCDIR/globalboost-tx}
GLOBALBOOSTQT=${GLOBALBOOSTQT:-$SRCDIR/qt/globalboost-qt}

[ ! -x $GLOBALBOOSTD ] && echo "$GLOBALBOOSTD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
BSTYVER=($($GLOBALBOOSTCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for globalboostd if --version-string is not set,
# but has different outcomes for globalboost-qt and globalboost-cli.
echo "[COPYRIGHT]" > footer.h2m
$GLOBALBOOSTD --version | sed -n '1!p' >> footer.h2m

for cmd in $GLOBALBOOSTD $GLOBALBOOSTCLI $GLOBALBOOSTTX $GLOBALBOOSTQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${BSTYVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${BSTYVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
