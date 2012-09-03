sub fix_shell {
    my $file = shift @_;
    my $rt = shift @_;
    #Is it a shell script
    if ($r[0] =~ /\#\!\/bin\/(ba|z|)sh/ || $r[0] =~ /\#\!\/bin\/env (ba|z|)sh/) {
        #Probably!
        #Handle with [-e foo -e bar]
	# http://www.pixelbeat.org/programming/shell_script_mistakes.html
        $rt =~ /\[\s*\-e\s*(\w+?)\s*\-e(\w+?)\s*\]/[-e $1] || [-e $2]/;
        #Double negative
        $rt =~ /\[\s*\!\-z\s*(\"\$\w*\"\)]/[$1]/;
        #Check for cat pipe to grep
	#i.e cat foo | grep baz
        $rt =~ s/^\s*cat\s*(\w+)\s*\|\s*grep\s+([\w\"]+)\s*$/grep $2 < $1/
    } else {
        return 0;
    }
    return $rt;
}
sub check_shell {
    my $file = shift @_;
    my $rt = shift @_;
    my @r = split(/\n/,$rt);
    #Is it a shell script?
    if ($r[0] =~ /\#\!\/bin\/(ba|z|)sh/ || $r[0] =~ /\#\!\/bin\/env (ba|z|)sh/) {
        #Probably!
        #Handle with [-e foo -e bar]
        if ($rt =~ /\[\s*\-e\s*\w*?\s*\-e\w*?\s*\]/) {
            return 1;
        }
        #Double negative
        if ($rt =~ /\[\s*\!\-z\"\$\w*\"\]/) {
            return 1;
        }
        #Check for cat pipe to grep
        if ($rt =~ /cat\s*\w+\s*\|\s*grep\s+[\w\"]+/) {
            return 1;
        }
    } else {
        return 0;
    }
    return 0;
}

use base 'Exporter';
our @EXPORT = qw{check_shell fix_shell};

1;
