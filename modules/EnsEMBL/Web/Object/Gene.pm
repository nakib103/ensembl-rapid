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


sub get_homology_matches {
  my $self = shift;

  my $homology_source = 'ENSEMBL_HOMOLOGUES';
  my $homology_description = 'homolog';
  my $key = "$homology_source::$homology_description";
  
  my $desc_mapping = {
                      'homolog_bbh'   => 'BH',
                      'homolog_rbbh'  => 'RBH',
                      };

  if (!$self->{'homology_matches'}{$key}) {
    my $homologues = $self->fetch_homology_species_hash($homology_source, $homology_description);
  
    return $self->{'homology_matches'}{$key} = {} unless keys %$homologues;

    my $gene         = $self->Obj;
    my $geneid       = $gene->stable_id;
    my $adaptor_call = $self->param('gene_adaptor') || 'get_GeneAdaptor';
    my %homology_list;

    foreach my $display_spp (keys %$homologues) {
      my $order = 0;

      foreach my $homology (@{$homologues->{$display_spp}}) {
        my ($homologue, $homology_desc, $query_perc_id, $target_perc_id, $homology_id) = @$homology;

        next unless $homology_desc =~ /$homology_description/;

        $homology_list{$display_spp}{$homologue->stable_id} = {
            homologue           => $homologue,
            homology_desc       => $desc_mapping->{$homology_desc},
            query_perc_id       => $query_perc_id || 0,
            target_perc_id      => $target_perc_id || 0,
            order               => $order,
          };   
        $order++;
      }
    }
    $self->{'homology_matches'}{$key} = \%homology_list;
  }
  return $self->{'homology_matches'}{$key};
}

sub fetch_homology_species_hash {
  my ($self, $homology_source, $homology_description) = @_;

  my ($homologies, $classification, $query_member) = $self->get_homologies($homology_source, $homology_description, 'compara');
  warn "@@@ HOMOLOGIES: ".scalar(@$homologies);

  my $name_lookup = $self->hub->species_defs->production_name_lookup;
  my %homologues;

  foreach my $homology (@$homologies) {
    warn ">>> HOMOLOGY $homology";
    my ($query_perc_id, $target_perc_id, $genome_db_name, $target_member);

    my $mlss = $homology->method_link_species_set;
    my $spp  = $mlss->species_set->genome_dbs;
    warn ">>> SPECIES @$spp";
    my $species;

    foreach (@{$spp||[]}) {
      warn "... GENOME ".$_->name;
      if ($_->name ne $self->hub->species_defs->SPECIES_PRODUCTION_NAME) {
        $species = $_->name;
      }
    }
    warn "!!! HOMOLOGOUS SPECIES: $species";

    foreach my $member (@{$homology->get_all_Members}) {
      $target_member  = $member->gene_member;
      $target_perc_id = $member->perc_id;
    }

    my $species_url = $name_lookup->{$species};

    push @{$homologues{$species_url}}, [ $target_member, $homology->description, $query_perc_id, $target_perc_id, $homology->dbID];
  }

  @{$homologues{$_}} = sort { $classification->{$a->[2]} <=> $classification->{$b->[2]} } @{$homologues{$_}} for keys %homologues;

  return \%homologues;
}

1;
