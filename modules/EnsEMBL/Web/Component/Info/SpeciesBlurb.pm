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

package EnsEMBL::Web::Component::Info::SpeciesBlurb;

use strict;

use EnsEMBL::Web::Utils::UrlFormatting qw(format_ftp_url);

sub page_header {
  my $self      = shift;
  my $hub       = $self->hub;
  my $sci_name  = $hub->species_defs->SPECIES_SCIENTIFIC_NAME;

  my $html = sprintf '<div class="round-box tinted-box unbordered"><h2>Search <i>%s</i></h2>%s</div>',
                        $sci_name, EnsEMBL::Web::Document::HTML::HomeSearch->new($hub)->render;

  return $html;
}

sub column_left {
  my $self      = shift;
  my $species   = $self->hub->species;

  my $html = '<div class="column-padding no-left-margin">';

  my $img_url      = $self->img_url;
  $self->{'icon'}  = qq(<img src="${img_url}24/%s.png" alt="" class="homepage-link" />);
  $self->{'img_link'} = qq(<a class="nodeco _ht _ht_track" href="%s" title="%s"><img src="${img_url}96/%s.png" alt="" class="bordered" />%s</a>);

  $html .= sprintf('
    <div class="round-box tinted-box unbordered">%s</div>
    <div class="round-box tinted-box unbordered">%s</div>',
    $self->assembly_text,
    $self->genebuild_text);

  if ($self->hub->database('variation')) {
    $html .= sprintf('<div class="round-box tinted-box unbordered">%s</div>', 
                $self->variation_text);
  }

  $html .= '</div>';

  return $html;
}

sub assembly_text {
  my $self      = shift;
  my $hub               = $self->hub;
  my $species_defs      = $hub->species_defs;
  my $species           = $hub->species;
  my $species_prod_name = $species_defs->get_config($species, 'SPECIES_PRODUCTION_NAME');
  my $sample_data       = $species_defs->SAMPLE_DATA;
  my $ftp               = $species_defs->ENSEMBL_FTP_URL;
  my $assembly          = $species_defs->ASSEMBLY_NAME;
  my $assembly_version  = $species_defs->ASSEMBLY_VERSION;
  my $gca               = $species_defs->ASSEMBLY_ACCESSION;

  my $karyotype = '';
  if (scalar @{$species_defs->ENSEMBL_CHROMOSOMES || []} && !$species_defs->NO_KARYOTYPE) {
    $karyotype = sprintf($self->{'img_link'},
                  $hub->url({ type => 'Location', action => 'Genome', __clear => 1 }),
                  'Go to ' . $species_defs->SPECIES_SCIENTIFIC_NAME . ' karyotype',
                  'karyotype', 'View karyotype'
                  );
  }

  my $other_assemblies = '';
  my $assembly_dropdown = $self->assembly_dropdown;
  if ($assembly_dropdown) {
    $other_assemblies = sprintf '<h3 class="light top-margin">Other assemblies</h3>%s', $assembly_dropdown;
  }

  my $html = sprintf('
    <div class="homepage-icon">
      %s
      %s
    </div>
    <h2>Genome assembly: %s%s</h2>
    %s
    <p><a href="%s" class="modal_link nodeco" rel="modal_user_data">%sDisplay your data in %s</a></p>
%s',

    $karyotype,

    sprintf(
      $self->{'img_link'},
      $hub->url({ type => 'Location', action => 'View', r => $sample_data->{'LOCATION_PARAM'}, __clear => 1 }),
      "Go to $sample_data->{'LOCATION_TEXT'}", 'region', 'Example region'
    ),

    $assembly, 
    $gca ? " <small>($gca)</small>" : '',

    $ftp ? sprintf(
      '<p><a href="%s" class="nodeco">%sDownload DNA sequence</a> (FASTA)</p>', ## Link to FTP site
      format_ftp_url($hub), sprintf($self->{'icon'}, 'download')
    ) : '',

    $hub->url({ type => 'UserData', action => 'SelectFile', __clear => 1 }), 

    sprintf($self->{'icon'}, 'page-user'), 
    $species_defs->ENSEMBL_SITETYPE,
    $other_assemblies
  );

  return $html;
}

sub assembly_dropdown {
  my $self = shift;
  my $species_defs = $self->hub->species_defs;

  my @assemblies;
  my $html = '';

  foreach my $species ($species_defs->valid_species) {
    next if $species eq $self->hub->species;
    my $sci_name = $species_defs->get_config($species, 'SPECIES_SCIENTIFIC_NAME');

    if ($sci_name eq $species_defs->SPECIES_SCIENTIFIC_NAME) {
      push @assemblies, {
        url   => sprintf('/%s/', $species),
        name  => $species_defs->get_config($species, 'SPECIES_DISPLAY_NAME'),
      };
    }
  }

  if (scalar @assemblies) {
    if (scalar @assemblies > 1) {
      $html .= qq(<form action="#" method="get" class="_redirect"><select name="url">);
      $html .= qq(<option value="$_->{'url'}">$_->{'name'}</option>) for @assemblies;
      $html .= '</select> <input type="submit" name="submit" class="fbutton" value="Go" /></form>';
    } else {
      $html .= qq(<ul><li><a href="$assemblies[0]{'url'}" class="nodeco">$assemblies[0]{'name'}</a></li></ul>);
    }
  }

  return $html;
}

sub genebuild_text {
  my $self         = shift;
  my $hub          = $self->hub;
  my $species_defs = $hub->species_defs;
  my $species      = $hub->species;
  my $sp_prod_name = $species_defs->get_config($species, 'SPECIES_PRODUCTION_NAME');
  my $sample_data  = $species_defs->SAMPLE_DATA;
  my $ftp          = $species_defs->ENSEMBL_FTP_URL;
  my $vega         = $species_defs->SUBTYPE !~ /Archive|Pre/ && $species_defs->get_config('MULTI', 'ENSEMBL_VEGA') || {};
  my $idm_link     = $species_defs->ENSEMBL_IDM_ENABLED
    ? sprintf('<p><a href="%s" class="nodeco">%sUpdate your old Ensembl IDs</a></p>', $hub->url({ type => 'Tools', action => 'IDMapper', __clear => 1 }), sprintf($self->{'icon'}, 'tool'))
    : '';

  return sprintf('
    <div class="homepage-icon">
      %s
      %s
    </div>
    <h2>Gene annotation</h2>
    <p><strong>What can I find?</strong> Protein-coding and non-coding genes, splice variants, cDNA and protein sequences, non-coding RNAs.</p>
    %s
    %s',

    sprintf(
      $self->{'img_link'},
      $hub->url({ type => 'Gene', action => 'Summary', g => $sample_data->{'GENE_PARAM'}, __clear => 1 }),
      "Go to gene $sample_data->{'GENE_TEXT'}", 'gene', 'Example gene'
    ),

    sprintf(
      $self->{'img_link'},
      $hub->url({ type => 'Transcript', action => 'Summary', t => $sample_data->{'TRANSCRIPT_PARAM'} }),
      "Go to transcript $sample_data->{'TRANSCRIPT_TEXT'}", 'transcript', 'Example transcript'
    ),

    $ftp ? sprintf(
      '<p><a href="%s" class="nodeco">%sDownload FASTA, GTF or GFF3</a> files for genes, cDNAs, ncRNA, proteins</p>', ## Link to FTP site
      format_ftp_url($hub, $hub->species, 'geneset'), sprintf($self->{'icon'}, 'download')
    ) : '',

    $idm_link
  );
}

sub variation_text {
  my $self              = shift;
  my $hub               = $self->hub;
  my $species_defs      = $hub->species_defs;
  my $species_prod_name = $species_defs->get_config($hub->species, 'SPECIES_PRODUCTION_NAME');

  my $sample_data  = $species_defs->SAMPLE_DATA;

  ## Is this species VCF-driven?
  my $meta_info = $hub->species_defs->databases->{'DATABASE_VARIATION'}{'meta_info'}->{1};
  my $vcf_only  = $meta_info && $meta_info->{'variation_source.database'}->[0] eq '0';

  ## Split variation param if required (e.g. vervet monkey)
  my ($v, $vf) = split(';vf=', $sample_data->{'VARIATION_PARAM'});
  my %v_params = ('v' => $v);
  $v_params{'vf'} = $vf if $vf;

  my $ftp = $self->ftp_url;
  my $html = sprintf('
      <div class="homepage-icon">
        %s
      </div>
      <h2>Variation</h2>
      <p><strong>What can I find?</strong> Short sequence variants</p>
      <p><a href="/info/genome/variation/" class="nodeco">%sMore about variation in %s</a></p>
      %s',

      $v ? sprintf(
        $self->{'img_link'},
        $hub->url({ type => 'Variation', action => 'Explore', __clear => 1, %v_params }),
        "Go to variant $sample_data->{'VARIATION_TEXT'}", 'variation', 'Example variant'
      ) : '',

      sprintf($self->{'icon'}, 'info'), $species_defs->ENSEMBL_SITETYPE,

      ($ftp && !$vcf_only) ? sprintf(
        '<p><a href="%s/variation/gvf/%s/" class="nodeco">%sDownload all variants</a> (GVF)</p>', ## Link to FTP site
        $ftp, $species_prod_name, sprintf($self->{'icon'}, 'download')
      ) : ''
  );

  return $html;
}


1;
