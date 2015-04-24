# Sources *.sh in the following directories in this order:
# /usr/share/cont-layer/$1/$2.d
# /usr/share/cont-volume/$1/$2.d
cont_source_scripts() {
    [ -z "$2" ] && return
    for dir in cont-layer cont-volume ; do
        full_dir="/usr/share/$dir/${1}/${2}.d"
        for i in ${full_dir}/*.sh; do
            if [ -r "$i" ]; then
                . "$i"
            fi
        done
    done
}

