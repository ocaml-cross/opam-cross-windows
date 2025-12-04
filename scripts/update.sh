#!/bin/bash

set -e

. $(dirname $0)/config.sh
[ -e $(dirname $0)/local.sh ] && . $(dirname $0)/local.sh

${DRY_RUN} git reset --hard HEAD
${DRY_RUN} opam update ${SUFFIX}

PACKAGES=$*
if [ -z "${PACKAGES}" ]; then
  PACKAGES=packages/*
fi

for pkg in ${PACKAGES}; do
  pkgcur=${pkg/-${SUFFIX}/}
  pkgname=${pkgcur/.*/}
  if ! [ -e "${UPSTREAM}/${pkgname}" ]; then
    continue
  fi
  if echo "${SKIP_PACKAGES}" | grep "${pkg/packages\//}"; then
    continue
  fi
  pkgupstream=packages/`(cd ${UPSTREAM}/${pkgname} && ls) | sort -rV | head -n1`
  if [ "${pkgcur}" != "${pkgupstream}" ]; then
    vercur=$(sed 's/[^.]\+\.//' <<<"${pkg}")
    vernew=$(sed 's/[^.]\+\.//' <<<"${pkgupstream}")
    echo -e "UPDATING: $(printf "%20s" ${pkgname}) ${vercur} -> ${vernew}"

    pkgnew=${pkgupstream/./-${SUFFIX}.}
    ${DRY_RUN} git mv ${pkg} ${pkgnew}
    diff -u ${UPSTREAM}/${pkgname}/${pkgupstream/packages\//}/opam ${pkgnew}/opam || true
    ${DRY_RUN} cp ${UPSTREAM}/${pkgname}/${pkgupstream/packages\//}/url ${pkgnew}/url
    ${DRY_RUN} git add ${pkgnew}/url

    speccur=${pkg/packages\//}
    specnew=${pkgnew/packages\//}
    ${DRY_RUN} opam remove -y ${speccur}
    ${DRY_RUN} opam update ${SUFFIX}
    ${DRY_RUN} opam install -y ${specnew}
    ${DRY_RUN} git commit -m "${speccur/.*/}.{${vercur}→${vernew}}"
    ${DRY_RUN} opam remove -y ${specnew} -a

    if [ -n "${ONLY_ONE}" ]; then
      break
    fi
  fi
done
