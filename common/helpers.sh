declare -A parameters=()
declare -a overlays=()

_usage () {
cat << EOF
USAGE: `basename $0` INTERNAL_OPTS OPTIONS

OPTIONS:
     --create-model
        Create Juju model using --name. Switches to model if it already
        exists. If this is not provided then the current Juju model is used.
     -h, --help
        Display this help message.
     --list
        List existing bundles.
     -n, --name n
        Name for bundle. If this is not provided then the default bundle
        location is used.
     -p, --pocket p
        Archive pocket to install packages from e.g. "proposed".
     -r, --release r
        Openstack release. This allows UCA to be used otherwise base archive
        of release is used.
     --replay
        Replay last command for bundle --name (or default bundle if no name
        provided).
     --run
        Automatically execute the generated deployment command.
     -s, --series s
        Ubuntu series.

INTERNAL_OPTS (don't use these):
     --bundle-params
        (internal only) Bundle paramaters passed by sub-generator
     --overlay p
        (internal only) Overlay to be added to deployment. Can be
        specified multiple times.
     --path p
        (internal only) Target bundle directory
     -t, --template t
        (internal only) Generated bundle templates.
EOF
}

get_units()
{
    units=`echo $1| sed -r 's/.+:([[:digit:]])/\1/;t;d'`
    [ -n "$units" ] || units=$3
    parameters[$2]=$units
}

get_param()
{
    read -p "$2" val
    parameters[$1]="$val"
}


generate()
{
for overlay in ${overlays[@]:-}; do
    opts+=( "--overlay $overlay" )
done
ftmp=
if ((${#parameters[@]})); then
    ftmp=`mktemp`
    echo -n "sed -i " > $ftmp
    for p in ${!parameters[@]}; do
        echo -n "-e 's/$p/${parameters[$p]}/g' " >> $ftmp
    done
    opts+=( --bundle-params $ftmp )
fi
`dirname $0`/common/generate-bundle.sh ${opts[@]}
[ -n "$ftmp" ] && rm $ftmp
}
