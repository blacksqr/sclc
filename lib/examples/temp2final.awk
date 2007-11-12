#
#temp2final.awk
#Linux Shell Scripting Tutorial v1.05, March 2001
#Author: Vivek G Gite
#

BEGIN{
}

#
# main logic is here
#
{
    sfile = $1
    dfile = $2
    cpcmd = "cp " $1 " " $2
    printf "Coping %s to %s\n",sfile,dfile
    system(cpcmd)
}

#
# End action, if any, e.g. clean ups
#
END{
}
