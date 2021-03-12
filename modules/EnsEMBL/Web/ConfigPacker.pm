=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
Copyright [2016-2018] EMBL-European Bioinformatics Institute

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
  $self->_summarise_xref_types('DATABASE_' . uc $_) for @tables;
  $self->_summarise_variation_db('variation', 'DATABASE_VARIATION');
  $self->_summarise_compara_db('compara', 'DATABASE_COMPARA');
}

sub munge_databases_multi {
  my $self = shift;
  $self->_summarise_website_db;
  $self->_summarise_go_db;
  $self->_summarise_compara_db('compara_pan_ensembl', 'DATABASE_COMPARA_PAN_ENSEMBL');
}

sub _summarise_compara_db {
## Stripped-down version, as not much data in these per-species compara dbs
  my ($self, $code, $db_name) = @_;

  my $dbh = $self->db_connect($db_name);
  return unless $dbh;

  push @{$self->db_tree->{'compara_like_databases'}}, $db_name;

  $self->_summarise_generic($db_name, $dbh);

  # Get list of species in the compara db (should just be one for rapid!)
  my $spp_aref = $dbh->selectall_arrayref('select name from genome_db');

  foreach my $row (@$spp_aref) {
    my $name = $row->[0];
    $self->db_tree->{$db_name}{'COMPARA_SPECIES'}{$name} = 1;
  }

  my %valid_species = map { $_ => 1 } keys %{$self->full_tree};

  my %sections = (
  );

  my $res_aref = $dbh->selectall_arrayref(qq{
    select ml.type, gd1.name, gd2.name
      from genome_db gd1, genome_db gd2, species_set ss1, species_set ss2,
       method_link ml, method_link_species_set mls1,
       method_link_species_set mls2
     where mls1.method_link_species_set_id = mls2.method_link_species_set_id and
       ml.method_link_id = mls1.method_link_id and
       ml.method_link_id = mls2.method_link_id and
       gd1.genome_db_id != gd2.genome_db_id and
       mls1.species_set_id = ss1.species_set_id and
       mls2.species_set_id = ss2.species_set_id and
       ss1.genome_db_id = gd1.genome_db_id and
       ss2.genome_db_id = gd2.genome_db_id
  });

  #use Data::Dumper;
  #$Data::Dumper::Sortkeys = 1;
  foreach my $row (@$res_aref) {
    my $key = $sections{uc $row->[0]} || uc $row->[0];
    my ($species1, $species2) = ($row->[1], $row->[2]);
    $self->db_tree->{$db_name}{$key}{$species1}{$species2} = $valid_species{$species2};
    #warn ">>> FOUND $key: ".Dumper($self->db_tree->{$db_name}{$key});
  }

  $dbh->disconnect;

}

1;
