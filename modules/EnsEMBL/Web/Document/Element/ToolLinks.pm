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

package EnsEMBL::Web::Document::Element::ToolLinks;

### Generates links in masthead

use strict;
use warnings;

use parent qw(EnsEMBL::Web::Document::Element);

use previous qw(links);

sub links {
  my $self  = shift;
  my $links = $self->PREV::links(@_);

  ## Aim to place this link before the one to the blog
  my $last_link = pop @$links;
  my $last_key = pop @$links;

  push @$links, 'known_bugs',  '<a class="constant" rel="nofollow" href="/info/data/known_bugs.html">Known Bugs</a>';

  push @$links, $last_key, $last_link;

  return $links;
}


1;
