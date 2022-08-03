=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
Copyright [2016-2021] EMBL-European Bioinformatics Institute

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

package EnsEMBL::Web::Component::Summary;

sub get_extra_rows {
  my ($self, $page_type) = @_;
  my $object  = $self->object;
  my $hub     = $self->hub;

  ## This is really hacky but it will do for now!
  my $sci_name = $hub->species_defs->SPECIES_SCIENTIFIC_NAME;
  return unless $sci_name eq 'Homo sapiens';
  $sci_name =~ s/ /_/;

  my (@rows, $gene, $param);
  if ($page_type eq 'gene') {
    $param  = 'g';
    $gene   = $object->Obj;
  }
  else {
    $param  = 't';
    $gene   = $object->gene;
  }
  my $attrib = 'proj_parent_'.$param;
  my @proj_attrib = @{ $gene->get_all_Attributes($attrib) };

  if (@proj_attrib) {
    (my $ref_id = $proj_attrib[0]->value) =~ s/\.\d+$//;


    my $ref_url  = $hub->url({
          species => $sci_name,
          type    => $hub->type,
          action  => 'Summary',
          $param  => $ref_id
        });
    push @rows, ["Reference equivalent", qq{<a href="https://www.ensembl.org/$ref_url">$ref_id</a>}];
  }

  return @rows;
}

1;
