#!/usr/bin/env perl
use Mojolicious::Lite;
use SVG;

any '/' => sub {
  my $c = shift;
  $c->param(height => 70) unless defined $c->param('height');
  $c->param(width => 100) unless defined $c->param('width');
  $c->param(depth => 30) unless defined $c->param('depth');
  $c->render(template => 'index');
};

my $x_offset = 50;
my $y_offset = 185;

get '/svg' => sub {
  my $c = shift;
  my ($height, $width, $depth) = ( $c->param('height') // 70, $c->param('width') // 100, $c->param('depth') // 30 );
  my $w_flap = int 0.15*$width;
  my $h_flap = int 0.15*$height;
  my $d_flap = int $depth/2;

  $x_offset = $depth+$w_flap+5;
  $y_offset = 2*$depth+$height+2*$h_flap+20;

  my $svg = SVG->new(width => $width+2*($depth+$w_flap)+15 . 'mm', height => 2*($height+$depth+$h_flap+1) + 30 . 'mm');

  # front
  $svg->cut_line([0,$height-$h_flap],[$h_flap,$height],[$width-$h_flap,$height],[$width,$height-$h_flap]);
  $svg->fold_line([0,0],[0,$height-$h_flap],[$width,$height-$h_flap],[$width,0]);
  $svg->fold_line([0,0], [$width,0]);

  # front sides
  $svg->cut_line([0,0],[-($depth+$w_flap),0],[-($depth+$w_flap),$height],[$h_flap,$height]);
  $svg->fold_line([-$depth,0],[-$depth,$height],[0,$height-$h_flap]);
  $svg->cut_line([$width,0],[$width+$depth+$w_flap,0],[$width+$depth+$w_flap,$height],[$width-$h_flap,$height]);
  $svg->fold_line([$width+$depth,0],[$width+$depth,$height],[$width,$height-$h_flap]);

  # bottom
  $svg->cut_line([0,0],[-$h_flap,0],[-$h_flap,-$depth],[0,-$depth]);
  $svg->cut_line([$width,0],[$width+$h_flap,0],[$width+$h_flap,-$depth],[$width,-$depth]);
  $svg->fold_line([0,0],[0,-$depth],[$width,-$depth],[$width,0]);

  # back
  $svg->cut_line([0,-$depth],[0,-($depth+$height)]);
  $svg->cut_line([$width,-$depth],[$width,-($depth+$height)]);
  $svg->fold_line([0,-($depth+$height)],[$width,-($depth+$height)]);

  # lid
  $svg->fold_line([0,-($depth+$height)],[0,-(2*$depth+$height)],[$width,-(2*$depth+$height)],[$width,-($depth+$height)]);
  $svg->cut_line([0,-($depth+$height)],[-($h_flap*2+11),-($depth+$height)],[-($h_flap*2+11),-(2*$depth+$height)],[0,-(2*$depth+$height)]);
  $svg->fold_line([-($h_flap+6),-($depth+$height)],[-($h_flap+6),-(2*$depth+$height)]);
  $svg->cut_line([$width,-($depth+$height)],[$width+$h_flap*2+11,-($depth+$height)],[$width+$h_flap*2+11,-(2*$depth+$height)],[$width,-(2*$depth+$height)]);
  $svg->fold_line([$width+$h_flap+6,-($depth+$height)],[$width+$h_flap+6,-(2*$depth+$height)]);

  # lid lip
  $svg->fold_line([0,-(2*$depth+$height)],[0,-(2*$depth+$height+$h_flap+5)],[$width,-(2*$depth+$height+$h_flap+5)],[$width,-(2*$depth+$height)]);
  $svg->cut_line([0,-(2*$depth+$height)],[-$depth,-(2*$depth+$height)],[-$depth,-(2*$depth+$height+$h_flap+5)],[0,-(2*$depth+$height+$h_flap+5)]);
  $svg->cut_line([$width,-(2*$depth+$height)],[$width+$depth,-(2*$depth+$height)],[$width+$depth,-(2*$depth+$height+$h_flap+5)],[$width,-(2*$depth+$height+$h_flap+5)]);
  $svg->fold_line([0,-(2*$depth+$height+$h_flap)],[0,-(2*$depth+$height+2*$h_flap+9)]);
  $svg->fold_line([$width,-(2*$depth+$height+2*$h_flap+9)],[$width,-(2*$depth+$height+$h_flap)]);
  $svg->cut_line([-$depth,-(2*$depth+$height+$h_flap+5)],[-$depth,-(2*$depth+$height+2*$h_flap+9)],[$width+$depth,-(2*$depth+$height+2*$h_flap+9)],[$width+$depth,-(2*$depth+$height+$h_flap+5)]);

  $c->render(data => $svg->xmlify, format => 'svg');
};

sub SVG::cut_line {
  my $svg = shift;
  my @points = @_;
  my $from = shift @points;

  while (@points) {
    my $to = shift @points;
    $svg->line(
      x1 => $from->[0]+3+$x_offset . 'mm', y1 => $from->[1]+3+$y_offset . 'mm',
      x2 => $to->[0]  +3+$x_offset . 'mm', y2 => $to->[1]  +3+$y_offset . 'mm',
      style => { stroke => 'black', 'stroke-width' => 1, }
    );
    $from = $to;
  }
}

sub SVG::fold_line {
  my $svg = shift;
  my @points = @_;
  my $from = shift @points;

  while (@points) {
    my $to = shift @points;
    $svg->line(
      x1 => $from->[0]+3+$x_offset . 'mm', y1 => $from->[1]+3+$y_offset . 'mm',
      x2 => $to->[0]  +3+$x_offset . 'mm', y2 => $to->[1]  +3+$y_offset . 'mm',
      style => { stroke => 'black', 'stroke-width' => 1, 'stroke-dasharray' => '6,2'}
    );
    $from = $to;
  }
}


app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
%= image url_for('svg')->query(height => param('height'), width => param('width'), depth => param('depth'));
%= form_for '/' => (method => 'POST') => begin
  %= t label => begin
    Height:
  %= text_field 'height'
  %= end
  <br>
  %= t label => begin
    Width:
  %= text_field 'width'
  %= end
  <br>
  %= t label => begin
    Depth:
  %= text_field 'depth'
  %= end
  <br>
  %= submit_button 'Render'
%= end

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head>
    <title><%= title %></title>
    <style>
      body { text-align: center; margin-left: auto; margin-right: auto; }
      @media print {
        form { display: none; }
      }
    </style>
  </head>
  <body><%= content %></body>
</html>
