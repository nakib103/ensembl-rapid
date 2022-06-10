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

package EnsEMBL::Web::Object::Gene;


sub get_homologues {
  my $self = shift;

  my $homology_source = 'ENSEMBL_HOMOLOGUES';
  my $homology_description = 'homolog';
  
  my ($homologies, $classification, $query_member) = $self->get_homologies($homology_source, $homology_description, 'compara');

  my $homologues = {};
  my $lookup     = $self->hub->species_defs->prodnames_to_urls_lookup;

  foreach my $homology (@$homologies) {
    #use Data::Dumper;
    #$Data::Dumper::Sortkeys = 1;
    #$Data::Dumper::Maxdepth = 2;
    #warn "\n>>> HOMOLOGY ".Dumper($homology);
    my ($reference, $identity, $coverage);
    #warn "\n\n....................";

    foreach my $member (@{$homology->get_all_Members}) {
      #warn Dumper($member);
      if ($member->genome_db->name eq $self->hub->species_defs->SPECIES_PRODUCTION_NAME) {
        $identity = sprintf('%.2f', $member->perc_id) || 0;
        $coverage = sprintf('%.2f', $member->perc_cov) || 0;
      }
      else {
        $reference  = $member->gene_member;
      }
    }
    my $url = $lookup->{$reference->genome_db->name};

    $homologues->{$reference->genome_db->display_name} = {
                                'url'         => $url,
                                'reference'   => $reference, 
                                'description' => $homology->description, 
                                'identity'    => $identity, 
                                'coverage'    => $coverage,
                              };
  }

  return $homologues;
}

1;
