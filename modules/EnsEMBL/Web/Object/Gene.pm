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

package EnsEMBL::Web::Object::Gene;


sub get_homologues {
  my $self = shift;

  my $homology_source = 'ENSEMBL_HOMOLOGUES';
  my $homology_description = 'homolog';
  
  my ($homologies, $classification, $query_member) = $self->get_homologies($homology_source, $homology_description, 'compara');

  my $desc_mapping = {
                      'homolog_bbh'   => 'BH',
                      'homolog_rbbh'  => 'RBH',
                      };

  my $homologues = {};

  foreach my $homology (@$homologies) {
    #use Data::Dumper;
    #$Data::Dumper::Maxdepth = 2;
    #warn "\n>>> HOMOLOGY ".Dumper($homology);
    my ($reference, $query_perc_id, $target_perc_id);

    foreach my $member (@{$homology->get_all_Members}) {
      if ($member->stable_id eq $self->stable_id) {
        $query_perc_id = $member->perc_id || 0;
      }
      else {
        #warn Dumper($member);
        $reference  = $member->gene_member;
        $target_perc_id = $member->perc_id || 0;
      }
    }

    $homologues->{$reference->genome_db->display_name} = {
                                'reference'       => $reference, 
                                'description'     => $desc_mapping->{$homology->description}, 
                                'query_perc_id'   => $query_perc_id, 
                                'target_perc_id'  => $target_perc_id
                              };
  }

  return $homologues;
}

1;
