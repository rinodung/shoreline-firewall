package Shorewall::Common;
require Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(warning_message 
		 fatal_error
		 emit 
		 emit_unindented
		 save_progress_message
		 save_progress_message_short
		 progress_message
		 progress_message2
		 progress_message3
		 push_indent
		 pop_indent
		 copy
		 copy1
		 append_file

		 $line $object $lastlineblank);
our @EXPORT_OK = ();
our @VERSION = 1.00;

my $line = '';          # Current config file line
my $object = 0;         # Object file Handle Reference
my $lastlineblank = 0;  # Avoid extra blank lines in the output
my $indent        = '';

#
# Issue a Warning Message
#
sub warning_message 
{
    print STDERR "   WARNING: @_\n";
}

#
# Fatal Error
#
sub fatal_error
{
    print STDERR "   ERROR: @_\n";
    close $object, if $object;
    system "rm -rf $ENV{TMP_DIR}" if $ENV{TMP_DIR};
    die;
}

#
# Write the argument to the object file (if any) with the current indentation.
# 
# Replaces leading spaces with tabs as appropriate and suppresses consecutive blank lines.
#
sub emit ( $ ) {
    if ( $object ) {
	my $line = $_[0];

	unless ( $line =~ /^\s+$/ ) {
	    $line =~ s/^/$indent/gm if $indent && $line;
	    1 while $line =~ s/^        /\t/m;
	    print $object "$line\n";
	    $lastlineblank = 0;
	} else {
	    print $object '' unless $lastlineblank;
	    $lastlineblank = 1;
	}
    }
}

#
# Write passed message to the object with no indentation.
#

sub emit_unindented( $ ) {
    print $object "$_[0]\n" if $object;
}

#
# Write a progress_message2 command to the output file.
#
sub save_progress_message( $ ) {
    emit "\nprogress_message2 $_[0]\n" if $object;
}

sub progress_message {
    if ( $ENV{VERBOSE} > 1 ) {
	my $ts = '';
	$ts = ( localtime ) . ' ' if $ENV{TIMESTAMP};
	print "${ts}@_\n";
    }
}

sub timestamp() {
    my ($sec, $min, $hr) = ( localtime ) [0,1,2];
    printf '%02d:%02d:%02d ', $hr, $min, $sec;
}

sub progress_message2 {
    if ( $ENV{VERBOSE} > 0 ) {
	timestamp if $ENV{TIMESTAMP};
	print "@_\n";
    }
}

sub progress_message3 {
    if ( $ENV{VERBOSE} >= 0 ) {
	timestamp if $ENV{TIMESTAMP};
	print "@_\n";
    }
}

#
# Push/Pop Indent
#
sub push_indent() {
    $indent = "$indent    ";
}

sub pop_indent() {
    $indent = substr( $indent , 0 , ( length $indent ) - 4 );
}

sub save_progress_message_short( $ ) {
    emit "progress_message $_[0]" if $object;
}

#
# Functions for copying files into the object
#
sub copy( $ ) {
    my $file = $_[0];
    
    open IF , $file or fatal_error "Unable to open $file: $!";
	    
    while ( my $line = <IF> ) {
	$line =~ s/^/$indent/ if $indent;
	print $object $line;
    }

    close IF;
}

sub copy1( $ ) {
    my $file = $_[0];
    
    open IF , $file or fatal_error "Unable to open $file: $!";
	    
    my $do_indent = 1;

    while ( my $line = <IF> ) {
	if ( $line =~ /^\s+$/ ) {
	    print $object "\n";
	    $do_indent = 1;
	    next;
	}

	$line =~ s/^/$indent/ if $indent && $do_indent;
	print $object $line;
	$do_indent = ! ( $line =~ /\\$/ );
    }

    close IF;
}

sub append_file( $ ) {
    my $user_exit = find_file $_[0];

    unless ( $user_exit =~ /$env{SHAREDIR}/ ) {
	if ( -f $user_exit ) {
	    save_progress_message "Processing $user_exit ...";
	    copy1 $user_exit;
	}
    }   
}

1;