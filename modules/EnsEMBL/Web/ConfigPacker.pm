=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
Copyright [2016-2022] EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

package EnsEMBL::Web::ConfigPacker;

use strict;
use warnings;
no warnings qw(uninitialized);

sub munge_databases {
  my $self   = shift;
  my @tables = qw(core cdna otherfeatures rnaseq);
  $self->_summarise_core_tables($_, 'DATABASE_' . uc $_) for @tables;
  $self->_summarise_genome_size('core', 'DATABASE_CORE');
  $self->_summarise_xref_types('DATABASE_' . uc $_) for @tables;
  $self->_summarise_variation_db('variation', 'DATABASE_VARIATION');
  $self->_summarise_compara_db('compara', 'DATABASE_COMPARA');
}


sub _summarise_genome_size {
  my ($self, $code, $db_name) = @_;

  my $dbh = $self->db_connect($db_name);
  return unless $dbh;

  ## Used in species table
  my $aref = $dbh->selectall_arrayref(
    "select value from genome_statistics where statistic = 'ref_length'"
  );
  $self->db_tree->{'STATS_GENOME_SIZE'} = $aref->[0][0];

  $dbh->disconnect;
}

sub munge_databases_multi {
  my $self = shift;
  $self->_summarise_website_db;
  $self->_summarise_go_db;
  $self->_summarise_compara_db('compara_pan_ensembl', 'DATABASE_COMPARA');
}

sub _summarise_compara_db {
## Stripped-down version, as not much data in these per-species compara dbs
  my ($self, $code, $db_name) = @_;

  my $dbh = $self->db_connect($db_name);
  return unless $dbh;

  push @{$self->db_tree->{'compara_like_databases'}}, $db_name;

  $self->_summarise_generic($db_name, $dbh);

  $dbh->disconnect;
}

1;
