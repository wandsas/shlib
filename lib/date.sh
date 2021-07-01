# ~/lib/date.sh

### Date/Time utility functions ###

# @return YYYYMMDD_HMS (20181027_160749)
print_timestamp () {
	echo $(date +'%Y%m%d_%H%M%S')
}

# @return YYYYMMDD (20181027)
print_datestamp () {
    echo $(date +'%Y%m%d')
}

# @return YYYY/MM/DD (2018/10/27)
print_date () {
    echo $(date +'%Y/%m/%d')
}

# @return YYYY/MM/DD HH:MM:SS (2018/10/27 16:08:22)
print_datetime () {
	echo $(date +'%Y/%m/%d %H:%M:%S')
}

# @return @1267619929
print_unix_timestamp () {
    date -d @1267619929 
}
