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

use strict;

package EnsEMBL::RapidRelease::SiteDefs;

sub update_conf {
  $SiteDefs::ENSEMBL_SUBTYPE          = 'Rapid Release';
  $SiteDefs::FIRST_RELEASE_VERSION    = 100; ## Don't update this!
  $SiteDefs::ENSEMBL_RELEASE_DATE = '8 July 2022';
  $SiteDefs::RAPID_RELEASE_VERSION = 35;
  $SiteDefs::HAS_ANNOTATION           = 1;
  $SiteDefs::NO_REGULATION            = 1;
  $SiteDefs::NO_VARIATION             = 1;
  $SiteDefs::NO_COMPARA               = 0;
  $SiteDefs::SINGLE_SPECIES_COMPARA   = 1;
  $SiteDefs::ENSEMBL_MART_ENABLED     = 0;
  $SiteDefs::ENSEMBL_VR_ENABLED       = 0;

  $SiteDefs::ENSEMBL_EXTERNAL_SEARCHABLE    = 0;

  $SiteDefs::SPECIES_IMAGE_DIR          = defer { $SiteDefs::ENSEMBL_SERVERROOT.'/ensembl-rapid/'.$SiteDefs::DEFAULT_SPECIES_IMG_DIR };

  ## No need to update this - we override it from FAVOURITES.txt, but the webcode
  ## throws a hissy fit during server startup if this parameter isn't present
  $SiteDefs::ENSEMBL_PRIMARY_SPECIES  = 'Camarhynchus_parvulus_GCA_902806625.1';

  $SiteDefs::ENSEMBL_TAXONOMY_DIVISION_FILE = $SiteDefs::ENSEMBL_SERVERROOT.'/ensembl-rapid/conf/rr_divisions.json';

  ## Compara reference species info
  $SiteDefs::REFERENCE_LOOKUP_FILE    = $SiteDefs::ENSEMBL_SERVERROOT.'/ensembl-rapid/conf/REFERENCE_LOOKUP.json';
}

1;
