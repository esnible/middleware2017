#!/bin/bash
#

set -o errexit

SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Allow system:serviceaccount:istio-system:default (the default service account in the istio-system namespace)
# to read the default namespace.

kubectl apply -f $SCRIPTDIR/role.yaml