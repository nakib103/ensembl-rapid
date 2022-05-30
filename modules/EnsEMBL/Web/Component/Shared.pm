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

package EnsEMBL::Web::Component::Shared;

use EnsEMBL::Web::File::Utils::IO qw(file_exists);

sub _format_genebuild_method {
  my ($self, $meta_container) = @_;
  my $species_defs = $self->hub->species_defs;
  my $html;

  my $method  = $species_defs->GENEBUILD_METHOD;
  my $label   = $species_defs->GENEBUILD_METHOD_DISPLAY;
  unless ($label) {
    $label = ucfirst $method;
    $label =~ s/_/ /g;
  }       

  my $doc_dir = '/info/genome/genebuild/';
  my $doc_path = sprintf '%s%s.html', $doc_dir, $method;
  my $full_path = $self->hub->species_defs->ENSEMBL_SERVERROOT.'/ensembl-rapid/htdocs/'.$doc_path;
  my $file_check = file_exists($full_path, {'nice' => 1});
  unless ($file_check->{'sucess'}) {
    $doc_path = $doc_dir;
  } 

  $html = sprintf('<a href="%s">%s</a>', $doc_path, $label);

  return $html;
}

1;
