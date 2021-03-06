#!/usr/bin/perl -w

BEGIN {
    use strict;
    $0 =~ s/.*\///;

    die "$0: non-existent or invalid MDS_ROOT environment variable.\n" unless
      exists $ENV{MDS_ROOT} && -d $ENV{MDS_ROOT};
}

use strict;
use lib "$ENV{MDS_ROOT}/perl";
use Bio::AlignIO;
use Bio::SeqIO;
use Getopt::Long;

my $HA_LENGTH = 987;
my $start_base = 1;
my $sequence_len = $HA_LENGTH;
my $verbose = 0;

my $n_ok_sequences = 0;
my $n_short_sequences = 0;
my $n_incomplete_sequences = 0;

sub usage() {
    print STDERR "Usage: $0 -verbose -start-base 1 -length N file.msf\n";
    exit(1);
}

GetOptions('start-base=i' => \$start_base,
	   'length=i'     => \$sequence_len,
	   'verbose!'     => \$verbose,
	  );

usage() if $Getopt::Long::error;

my $out = Bio::SeqIO->new(-fh => \*STDOUT, -format => 'fasta');

for my $file (@ARGV) {
    my $in = Bio::AlignIO->new(-file => $file, -format => 'msf');

    while (my $aln = $in->next_aln()) {
        for my $s ($aln->each_seq) {
            if ($s->length() < $start_base + $sequence_len - 1) {
                warn sprintf("$0: sequence '%s' is too short, ignored.\n", $s->display_id) if $verbose;
                $n_short_sequences++;
                next;
            }

            $s->seq(uc($s->subseq($start_base, $start_base + $sequence_len - 1)));

            die sprintf("$0: unexpected incorrect length in truncated sequence '%s'.\n", $s->display_id)
              unless $s->length() == $sequence_len;

            if (0 && $s->seq !~ /^[ACGT]*$/) {
                if ($verbose) {
                    warn sprintf("$0: sequence '%s' is not composed of ACGT, ignoring. Sequence appears below\n", $s->display_id);

                    for (my $i = 0; $i < $sequence_len; $i++) {
                        if ($i % 10 == 0) {
                            printf STDERR $i / 10;
                            if ($i) {
                                my $l = int((log($i) / log(10))) - 1;
                                $i += $l if $l > 0;
                            }
                        }
                        else {
                            print STDERR ' ';
                        }
                    }
                    print STDERR "\n";

                    for (my $i = 0; $i < $sequence_len; $i++) {
                        printf STDERR "%d", $i % 10;
                    }
                    print STDERR "\n";
				
                    warn sprintf("%s\n%s\n",
                                 $s->seq,
                                 join('', map { $_ =~ /^[ACGT]$/i ? ' ' : '^' } split('' , $s->seq))
                                );
					
                }
                $n_incomplete_sequences++;
                next;
            }
	    
            # Chop off trailing .seq in strain id, if any.
            if ($s->display_id =~ /\.seq$/) {
                my $id = $s->display_id;
                substr($id, -4, 4, '');
                $s->display_id($id);
            }
			
            $out->write_seq($s);
            $n_ok_sequences++;
        }
    }

    if ($verbose) {
        printf STDERR "Number of sequences found in '$file': %d\n", $n_short_sequences + $n_incomplete_sequences + $n_ok_sequences;
        printf STDERR "Number too short: %d\n", $n_short_sequences;
        printf STDERR "Number incomplete: %d\n", $n_incomplete_sequences;
        printf STDERR "Number ok: %d\n", $n_ok_sequences;
    }
}

exit(0);
