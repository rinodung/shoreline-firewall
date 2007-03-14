package Shorewall::Config;

use strict;
use warnings;
use Shorewall::Common;

our @ISA = qw(Exporter);
our @EXPORT = qw(find_file do_initialize report_capabilities propagateconfig %config %env %capabilities );
our @EXPORT_OK = ();
our @VERSION = 1.00;

#
# From shorewall.conf file
#
my %config =     
              ( STARTUP_ENABLED => undef,
		VERBOSITY => undef,
		#
		# Logging
		#
		LOGFILE => undef,
		LOGFORMAT => undef,
		LOGTAGONLY => undef,
		LOGRATE => undef,
		LOGBURST => undef,
		LOGALLNEW => undef,
		BLACKLIST_LOGLEVEL => undef,
		MACLIST_LOG_LEVEL => undef,
		TCP_FLAGS_LOG_LEVEL => undef,
		RFC1918_LOG_LEVEL => undef,
		SMURF_LOG_LEVEL => undef,
		LOG_MARTIANS => undef,
		#
		# Location of Files
		#
		IPTABLES => undef,
		#PATH is inherited
		PATH => undef,
		SHOREWALL_SHELL => undef,
		SUBSYSLOCK => undef,
		MODULESDIR => undef,
		#CONFIG_PATH is inherited
		CONFIG_PATH => undef,
		RESTOREFILE => undef,
		IPSECFILE => undef,
		#
		# Default Actions/Macros
		#
		DROP_DEFAULT => undef,
		REJECT_DEFAULT => undef,
		ACCEPT_DEFAULT => undef,
		QUEUE_DEFAULT => undef,
		#
		# Firewall Options
		#
		BRIDGING => undef,
		IP_FORWARDING => undef,
		ADD_IP_ALIASES => undef,
		ADD_SNAT_ALIASES => undef,
		RETAIN_ALIASES => undef,
		TC_ENABLED => undef,
		TC_EXPERT => undef,
		CLEAR_TC => undef,
		MARK_IN_FORWARD_CHAIN => undef,
		CLAMPMSS => undef,
		ROUTE_FILTER => undef,
		DETECT_DNAT_IPADDRS => undef,
		MUTEX_TIMEOUT => undef,
		ADMINISABSENTMINDED => undef,
		BLACKLISTNEWONLY => undef,
		DELAYBLACKLISTLOAD => undef,
		MODULE_SUFFIX => undef,
		DISABLE_IPV6 => undef,
		DYNAMIC_ZONES => undef,
		PKTTYPE=> undef,
		RFC1918_STRICT => undef,
		MACLIST_TABLE => undef,
		MACLIST_TTL => undef,
		SAVE_IPSETS => undef,
		MAPOLDACTIONS => undef,
		FASTACCEPT => undef,
		IMPLICIT_CONTINUE => undef,
		HIGH_ROUTE_MARKS => undef,
		USE_ACTIONS=> undef,
		OPTIMIZE => undef,
		EXPORTPARAMS => undef,
		EXPERIMENTAL => undef,
		#
		# Packet Disposition
		#
		MACLIST_DISPOSITION => undef,
		TCP_FLAGS_DISPOSITION => undef,
		BLACKLIST_DISPOSITION => undef,
		ORIGINAL_POLICY_MATCH => undef,
		);
#
# Config options and global settings that are to be copied to object
#
my @propagateconfig = qw/ CLEAR_TC DISABLE_IPV6 ADMINISABSENTMINDED IP_FORWARDING MODULESDIR MODULE_SUFFIX LOGFORMAT SUBSYSLOCK/;
my @propagateenv    = qw/ LOGLIMIT LOGTAGONLY LOGRULENUMBERS /;


# Misc Globals
#
my %env  =   ( SHAREDIR => '/usr/share/shorewall' ,
	       CONFDIR =>  '/etc/shorewall',
	       LOGPARMS => '',
	       VERSION =>  '3.9.0',
	       );

#
# From parsing the capabilities file
#
my %capabilities = 
             ( NAT_ENABLED => undef,
	       MANGLE_ENABLED => undef,
	       MULTIPORT => undef,
	       XMULTIPORT => undef,
	       CONNTRACK_MATCH => undef,
	       USEPKTTYPE => undef,
	       POLICY_MATCH => undef,
	       PHYSDEV_MATCH => undef,
	       LENGTH_MATCH => undef,
	       IPRANGE_MATCH => undef,
	       RECENT_MATCH => undef,
	       OWNER_MATCH => undef,
	       IPSET_MATCH => undef,
	       CONNMARK => undef,
	       XCONNMARK => undef,
	       CONNMARK_MATCH => undef,
	       XCONNMARK_MATCH => undef,
	       RAW_TABLE => undef,
	       IPP2P_MATCH => undef,
	       CLASSIFY_TARGET => undef,
	       ENHANCED_REJECT => undef,
	       KLUDGEFREE => undef,
	       MARK => undef,
	       XMARK => undef,
	       MANGLE_FORWARD => undef,
	       COMMENTS => undef,
	       ADDRTYPE => undef,
	       );

my %capdesc = ( NAT_ENABLED     => 'NAT',
		MANGLE_ENABLED  => 'Packet Mangling',
		MULTIPORT       => 'Multi-port Match' ,
		XMULTIPORT      => 'Extended Multi-port Match',
		CONNTRACK_MATCH => 'Connection Tracking Match',
		USEPKTTYPE      => 'Packet Type Match',
		POLICY_MATCH    => 'Policy Match',
		PHYSDEV_MATCH   => 'Physdev Match',
		LENGTH_MATCH    => 'Packet length Match',
		IPRANGE_MATCH   => 'IP Range Match',
		RECENT_MATCH    => 'Recent Match',
		OWNER_MATCH     => 'Owner Match',
		IPSET_MATCH     => 'Ipset Match',
		CONNMARK        => 'CONNMARK Target',
		XCONNMARK       => 'Extended CONNMARK Target',
		CONNMARK_MATCH  => 'Connmark Match',
		XCONNMARK_MATCH => 'Extended Connmark Match',
		RAW_TABLE       => 'Raw Table',
		IPP2P_MATCH     => 'IPP2P Match',
		CLASSIFY_TARGET => 'CLASSIFY Target',
		ENHANCED_REJECT => 'Extended Reject',
		KLUDGEFREE      => 'Repeat match',
		MARK            => 'MARK Target',
		XMARK           => 'Extended Mark Target',
		MANGLE_FORWARD  => 'Mangle FORWARD Chain',
		COMMENTS        => 'Comments',
		ADDRTYPE        => 'Address Type Match',
		);
#
# Search the CONFIG_PATH for the passed file
#
sub find_file($) 
{
    my $filename=$_[0];

    if ( $filename =~ '/.*' ) {
	return $filename;
    }

    my $directory;

    for $directory ( split ':', $ENV{CONFIG_PATH} ) {
	my $file = "$directory/$filename";
	return $file if -f $file;
    }

    "$env{CONFDIR}/$filename";
}

sub default ( $$ ) {
    my ( $var, $val ) = @_;

    $config{$var} = $val unless defined $config{$var};
}

sub default_yes_no ( $$ ) {
    my ( $var, $val ) = @_;

    my $curval = "\L$config{$var}";

    if ( $curval ) {
	if (  $curval eq 'no' ) {
	    $config{$var} = '';
	} else {
	    fatal_error "Invalid value for $var ($val)" unless $curval eq 'yes';
	}
    } else {
	$config{$var} = $val;
    }
}

sub report_capabilities() {
    sub report_capability( $ ) {
	my $cap = $_[0];
	print "   $capdesc{$cap}: ";
	print $capabilities{$cap} ? "Available\n" : "Not Available\n";
    }
    
    print "Shorewall has detected the following capabilities:\n";
	
    for my $cap ( sort { $capdesc{$a} cmp $capdesc{$b} } keys %capabilities ) {
	report_capability $cap;
    }
}

#
# Read the shorewall.conf file and establish global hashes %config and %env.
#
sub do_initialize() {
    my $file = find_file 'shorewall.conf';

    if ( -f $file ) {
	if ( -r _ ) {
	    open CONFIG , $file or fatal_error "Unable to open $file: $!";

	    while ( $line = <CONFIG> ) {
		chomp $line;
		next if $line =~ /^\s*#/;
		next if $line =~ /^\s*$/;

		if ( $line =~ /^([a-zA-Z]\w*)\s*=\s*(.*)$/ ) {
		    my ($var, $val) = ($1, $2);
		    unless ( exists $config{$var} ) {
			warning_message "Unknown configuration option \"$var\" ignored";
			next;
		    }

		    $config{$var} = $val =~ /\"([^\"]*)\"$/ ? $1 : $val;
		} else {
		    fatal_error "Unrecognized entry in $file: $line";
		}
	    }

	    close CONFIG;
	} else {
	    fatal_error "Cannot read $file (Hint: Are you root?)";
	}
    } else {
	fatal_error "$file does not exist!";
    }

    $file = find_file 'capabilities';

    if ( -f $file ) {
	if ( -r _ ) {
	    open CAPS , $file or fatal_error "Unable to open $file: $!";

	    while ( $line = <CAPS> ) {
		chomp $line;
		next if $line =~ /^\s*#/;
		next if $line =~ /^\s*$/;

		if ( $line =~ /^([a-zA-Z]\w*)\s*=\s*(.*)$/ ) {
		    my ($var, $val) = ($1, $2);
		    unless ( exists $capabilities{$var} ) {
			warning_message "Unknown capability \"$var\" ignored";
			next;
		    }

		    $capabilities{$var} = $val =~ /^\"([^\"]*)\"$/ ? $1 : $val;
		} else {
		    fatal_error "Unrecognized entry in $file: $line";
		}
	    }

	    close CAPS;

	} else {
	    fatal_error "Cannot read $file (Hint: Are you root?)";
	}
    } else {
	fatal_error "$file does not exist!";
    }

    if ( $ENV{DEBUG} ) {
	print "\n";
	print "Capabilities:\n";
	for my $var (sort keys %capabilities) {
	    print "   $var=$capabilities{$var}\n";
	}
    }

    $env{ORIGINAL_POLICY_MATCH} = $capabilities{POLICY_MATCH};

    default 'MODULE_PREFIX', 'o gz ko o.gz ko.gz';

    if ( $config{LOGRATE} || $config{LOGBURST} ) {
	$env{LOGLIMIT} = '-m limit';
	$env{LOGLIMIT} .= " --limit $config{LOGRATE}"        if $config{LOGRATE};
	$env{LOGLIMIT} .= " --limit-burst $config{LOGBURST}" if $config{LOGBURST};
    } else {
	$env{LOGLIMIT} = '';
    }

    if ( $config{IP_FORWARDING} ) {
	fatal_error "Invalid value ( $config{IP_FORWARDING} ) for IP_FORWARDING" 
	    unless $config{IP_FORWARDING} =~ /^(On|Off|Keep)$/i;
    } else {
	$config{IP_FORWARDING} = 'On';
    }

    default_yes_no 'ADD_IP_ALIASES'             , 'Yes';
    default_yes_no 'ADD_SNAT_ALIASES'           , '';
    default_yes_no 'ROUTE_FILTER'               , '';
    default_yes_no 'LOG_MARTIANS'               , '';
    default_yes_no 'DETECT_DNAT_IPADDRS'        , '';
    default_yes_no 'DETECT_DNAT_IPADDRS'        , '';
    default_yes_no 'CLEAR_TC'                   , 'Yes';
    default_yes_no 'CLAMPMSS'                   , '' unless $config{CLAMPMSS} =~ /^\d+$/;

    unless ( $config{IP_ADD_ALIASES} || $config{ADD_SNAT_ALIASES} ) {
	$config{RETAIN_ALIASES} = '';
    } else {
	default_yes_no 'RETAIN_ALIASES'             , '';
    }

    default_yes_no 'ADMINISABSENTMINDED'        , '';
    default_yes_no 'BLACKLISTNEWONLY'           , '';
    default_yes_no 'DISABLE_IPV6'               , '';
    default_yes_no 'DYNAMIC_ZONES'              , '';

    fatal_error "DYNAMIC_ZONES=Yes is incompatible with the -e option" if $config{DYNAMIC_ZONES} and $ENV{EXPORT};
    
    default_yes_no 'STARTUP_ENABLED'            , 'Yes';
    default_yes_no 'DELAYBLACKLISTLOAD'         , '';
    default_yes_no 'LOGTAGONLY'                 , '';
    default_yes_no 'RFC1918_STRICT'             , '';
    default_yes_no 'SAVE_IPSETS'                , '';
    default_yes_no 'MAPOLDACTIONS'              , '';
    default_yes_no 'FASTACCEPT'                 , '';
    default_yes_no 'IMPLICIT_CONTINUE'          , '';
    default_yes_no 'HIGH_ROUTE_MARKS'           , '';
    default_yes_no 'TC_EXPERT'                  , '';
    default_yes_no 'USE_ACTIONS'                , 'Yes';
    default_yes_no 'EXPORTPARAMS'               , '';

    $capabilities{XCONNMARK} = '' unless $capabilities{XCONNMARK_MATCH} and $capabilities{XMARK};

    fatal_error 'HIGH_ROUTE_MARKS=Yes requires extended MARK support' if $config{HIGH_ROUTE_MARKS} and ! $capabilities{XCONNMARK};

    default 'BLACKLIST_DISPOSITION'             , 'DROP';
    
    my $val;

    $env{MACLIST_TARGET} = 'reject';

    if ( $val = $config{MACLIST_DISPOSITION} ) {
	unless ( $val eq 'REJECT' ) {
	    if ( $val eq 'DROP' ) {
		$env{MACLIST_TARGET} = 'DROP';
	    } elsif ( $val eq 'ACCEPT' ) {
		$env{MACLIST_TARGET} = 'RETURN';
	    } else {
		fatal_error "Invalid value ( $config{MACLIST_DISPOSITION} ) for MACLIST_DISPOSITION"
		}
	}
    } else {
	$config{MACLIST_DISPOSITION} = 'REJECT';
    }
    
    if ( $val = $config{MACLIST_TABLE} ) {
	if ( $val eq 'mangle' ) {
	    fatal_error 'MACLIST_DISPOSITION=REJECT is not allowed with MACLIST_TABLE=mangle' if $config{MACLIST_DISPOSITION} eq 'REJECT';
	} else {
	    fatal_error "Invalid value ($val) for MACLIST_TABLE option" unless $val eq 'filter';
	}
    } else {	
	default 'MACLIST_TABLE' , 'filter';
    }

    if ( $val = $config{TCP_FLAGS_DISPOSITION} ) {
	fatal_error "Invalid value ($config{TCP_FLAGS_DISPOSITION}) for TCP_FLAGS_DISPOSITION" unless $val =~ /^(REJECT|ACCEPT|DROP)$/;
    } else {
	$config{TCP_FLAGS_DISPOSITION} = 'DROP';
    }
	
    $env{TC_SCRIPT} = '';

    if ( $val = "\L$config{TC_ENABLED}" ) {
	if ( $val eq 'yes' ) {
	    $file = find_file 'tcstart';
	    fatal_error "Unable to find tcstart file" unless -f $file;
	} elsif ( $val ne 'internal' ) {
	    fatal_error "Invalid value ($config{TC_ENABLED}) for TC_ENABLED" unless $val eq 'no';
	    $config{TC_ENABLED} = '';
	}
    }

    if ( $config{MANGLE_ENABLED} ) {
	fatal_error 'Traffic Shaping requires mangle support in your kernel and iptables' unless $capabilities{MANGLE_ENABLED};
    }

    default 'MARK_IN_FORWARD_CHAIN' , '';
    default 'RESTOREFILE'           , 'restore';
    default 'DROP_DEFAULT'          , 'Drop';
    default 'REJECT_DEFAULT'        , 'Reject';
    default 'QUEUE_DEFAULT'         , 'none';
    default 'ACCEPT_DEFAULT'        , 'none';
    default 'OPTIMIZE'              , 0;
    default 'IPSECFILE'             , 'ipsec';
    
    for my $default qw/DROP_DEFAULT REJECT_DEFAULT QUEUE_DEFAULT ACCEPT_DEFAULT/ {
	$config{$default} = 'none' if "\L$config{$default}" eq 'none';
    }

    $val = $config{OPTIMIZE};

    fatal_error "Invalid OPTIMIZE value ($val)" unless ( $val eq '0' ) || ( $val eq '1' );

    fatal_error "Invalid IPSECFILE value ($config{IPSECFILE}" unless $config{IPSECFILE} eq 'zones';

    $env{MARKING_CHAIN} = $config{MARK_IN_FORWARD_CHAIN} ? 'tcfor' : 'tcpre';

    if ( $val = $config{LOGFORMAT} ) {
	my $result;

	eval {
	    if ( $val =~ /%d/ ) {
		$env{LOGRULENUMBERS} = 'Yes';
		$result = sprintf "$val", 'fooxx2barxx', 1, 'ACCEPT';
	    } else {
		$result = sprintf "$val", 'fooxx2barxx', 'ACCEPT';
	    }
	};

	fatal_error "Invalid LOGFORMAT ($val)" if $@;
	    
	fatal_error "LOGFORMAT string is longer than 29 characters: \"$val\"" 
	    if length $result > 29;

	$env{MAXZONENAMELENGTH} = int ( 5 + ( ( 29 - (length $result ) ) / 2) );
    } else {
	$env{LOGFORMAT}='Shorewall:%s:%s:';
	$env{MAXZONENAMELENGTH} = 5;
    }

    if ( $ENV{DEBUG} ) {
	print "\n";
	print "Configuration:\n";

	for my $var (sort keys %config) {
	    if ( defined $config{$var} ) {
		print "   $var=$config{$var}\n";
	    } else {
		print "   $var=\n";
	    }
	}

	print "\n";
	print "Environment:\n";

	for my $var (sort keys %env) {
	    print "   $var=$env{$var}\n" if $env{$var};
	}
    }

}

sub propagateconfig() {
    for my $option ( @Shorewall::Config::propagateconfig ) {
	my $value = $config{$option} || '';
	emit "$option=\"$value\"";
    }
    
    for my $option ( @Shorewall::Config::propagateenv ) {
	my $value = $env{$option} || '';
	emit "$option=\"$value\"";
    }
}

1;