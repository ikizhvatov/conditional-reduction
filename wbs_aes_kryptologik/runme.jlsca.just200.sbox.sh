DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../jlsca-evolution.sh

just200 $DIR/kryptologik.trs VANILLA
