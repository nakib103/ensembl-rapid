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

package EnsEMBL::Web::Utils::UrlFormatting;

use base qw(Exporter);

our @EXPORT = our @EXPORT_OK = qw(format_ftp_url);

sub format_ftp_url {
  my ($hub, $species, $link_type) = @_;
  my $sd  = $hub->species_defs;

  $species ||= $hub->species;
  my $url = sprintf '%s/species/%s/%s/%s',
              $sd->ENSEMBL_FTP_URL, 
              $sd->get_species_name($species),
              $sd->get_config($species, 'ASSEMBLY_ACCESSION'),
              (lc($sd->get_config($species, 'SPECIES_ANNOTATION_SOURCE')) || "ensembl");

  if ($link_type eq 'geneset') {
    $url .= '/geneset/';
  }
  elsif ($link_type eq 'rnaseq') {
    $url .= '/rnaseq/';
  }
  else {
    $url .= '/genome/';
  }

  return $url;
}

1;
