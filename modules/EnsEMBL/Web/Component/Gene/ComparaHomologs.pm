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

package EnsEMBL::Web::Component::Gene::ComparaHomologs;

use strict;

use EnsEMBL::Web::Utils::FormatText qw(helptip);

use base qw(EnsEMBL::Web::Component::Gene);

sub _init {
  my $self = shift;
  $self->cacheable(1);
  $self->ajaxable(1);
}

sub content {
  my $self         = shift;
  my $hub          = $self->hub;
  my $object       = $self->object;
  my $species_defs = $hub->species_defs;
  my $availability = $object->availability;

  unless ($availability->{'has_homologs'}) {
    return '<p>No homologues have been found for this gene.</p>';
  }

  ## N.B. we match both 'homolog_bbh' and 'homolog_rbbh' - each gene should match one or the other
  my $homologues = $object->get_homologues('ENSEMBL_HOMOLOGUES', 'homolog');

  my ($html, $columns, @rows);

  $columns = [
      {key => 'ref',    title => 'Reference species', align => 'left', width => '30%', sort => 'html'},
      {key => 'gene',   title => 'Homologue gene name', align => 'left', width => '20%', sort => 'html'},
      {key => 'hs_id',  title => 'Homologue stable id', align => 'left', width => '20%', sort => 'html'},
      {key => 'type',   title => 'Type', align => 'left', width => '10%', sort => 'html'},
      {key => 'identity',  title => '% Identity', align => 'left', width => '10%', sort => 'numeric'},
      {key => 'coverage', title => '% Coverage', align => 'left', width => '10%', sort => 'numeric'},
    ];
 
  my $lookup = $self->hub->species_defs->multi_val('REFERENCE_LOOKUP');

  my $desc_mapping = {
                      'homolog_bbh'   => ['BH', 'Best BLAST hit'],
                      'homolog_rbbh'  => ['RBH', 'Reciprocal best BLAST hit'],
                      };
 
  ## Sort by type first (RBH is better than BH, so reverse-sort) then by descending total % scores
  foreach my $species (sort {
                          $homologues->{$b}{'description'} cmp $homologues->{$a}{'description'}
                          || (($homologues->{$b}{'identity'} + $homologues->{$b}{'coverage'}) 
                                <=> ($homologues->{$a}{'identity'} + $homologues->{$a}{'coverage'}))
                            } keys %$homologues) { 
    my $homologue = $homologues->{$species};
    my $reference = $homologue->{'reference'};

    ## Link out to relevant site
    my $division  = $lookup->{$reference->genome_db->name}{'division'};
    my $version   = $reference->genome_db->first_release;
    my ($site, $sp_url);
    if ($division) {
      $site = 'https://%s.ensembl.org', $division eq 'www' ? "e$version" : $division;
      $sp_url    = $lookup->{$reference->genome_db->name}{'url'};
    }
    else {
      $site = '';
      $sp_url = $homologue->{'url'};
    }
    my $site      = $division ? sprintf('https://%s.ensembl.org', $division eq 'www' ? "e$version" : $division) : 'https://rapid.ensembl.org';
    my $href      = sprintf '<a href="%s/%s/Gene/Summary?g=%s">%s</a>', $site, $sp_url, $reference->stable_id, $reference->stable_id;

    my $type    = helptip(@{$desc_mapping->{$homologue->{'description'}}||[]});

    push @rows, {
      'ref'       => $species,
      'hs_id'     => $href,
      'gene'      => $reference->display_label, 
      'type'      => $type,
      'identity'  => $homologue->{'identity'}, 
      'coverage'  => $homologue->{'coverage'}, 
    }
  }

  $html .= $self->new_table($columns, \@rows, { data_table => 1})->render;

  return $html;
}


1;
