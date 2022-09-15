=head1 LICENSE

Copyright [1999-2016] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

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

package EnsEMBL::Web::ImageConfig;

sub add_data_files {
  my ($self, $key, $hashref) = @_;
  my $menu = $self->get_node('rnaseq');

  return unless $menu;

  my ($keys, $data) = $self->_merge($hashref->{'data_file'});

  foreach (@$keys) {
    my $glyphset = $data->{$_}{'format'} || '_alignment';

    my $renderers;
    if ($glyphset eq 'bamcov') {
      ## Quick'n'dirty hack until db is updated
      if ($self->hub->species_defs->ENSEMBL_SUBTYPE eq 'Rapid Release') {
        $renderers = [
                      'off',                  'Off',
                      'signal',               'Coverage (BigWig)',
                      ];
      }
      else {
        $renderers = [
                      'off',                  'Off',
                      'signal',               'Coverage (BigWig)',
                      ];
      }
    }
    else {
      $renderers = [
                    'off',                  'Off',
                    'coverage_with_reads',  'Normal',
                    'unlimited',            'Unlimited',
                    'histogram',            'Coverage only'
                    ];
    }

    $self->_add_track($menu, $key, "data_file_${key}_$_", $data->{$_}, {
      glyphset  => $glyphset,
      colourset => $data->{$_}{'colour_key'} || 'feature',
      strand    => 'f',
      renderers => $renderers,
      gang      => 'rnaseq',
      on_error  => 555,
    });
  }
}


1;
