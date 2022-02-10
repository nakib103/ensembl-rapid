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

package EnsEMBL::Web::Document::HTML::DocsHomepage;

sub get_annotation_html {
  my $self = shift;
  my $sd = $self->hub->species_defs;

  my $annotation = qq(
<h2 class="first"><a href="/info/genome/">Annotation &amp; Prediction</a></h2>
<p>The Ensembl project produces genome databases for vertebrates and other
eukaryotic species, and makes this information freely available online.</p>
<ul>
<li><a href="/info/genome/genebuild/">Ensembl annotation</a></li>

    );

  unless ($sd->NO_VARIATION) {
    $annotation .= qq(
<li><a href="/info/genome/variation/">Variation data</a></li>
    );
  }

  unless ($sd->NO_COMPARA) {
   $annotation .= qq(
<li><a href="/info/genome/compara/">Comparative genomics</a></li>
   );
  }

  unless ($sd->NO_REGULATION) {
    $annotation .= qq(
<li><a href="/info/genome/funcgen/">Regulatory build</a></li>
    );
  }

  $annotation .= qq(
</ul>
);
  return $annotation;
}

1;
