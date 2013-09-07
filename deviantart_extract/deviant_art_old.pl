#!/usr/bin/perl
use strict;
use warnings;
use LWP::UserAgent;
use HTML::Parser;
use HTML::TreeBuilder;
use URI::URL;
use HTTP::Request::Common qw(POST);
use HTTP::Request::Common qw(GET);
use HTTP::Cookies;
use LWP::Simple;
use HTML::FormatText;

my $ua = LWP::UserAgent->new;

# Define user agent type
$ua->agent('Mozilla/8.0');

# Request object
my $username =  "heath923.";  #"martanael.";
my $category = "/favourites";
my $base_url = "deviantart.com";
my $get_url = "http://www." . $username . $base_url . $category;
my $req = GET $get_url; 
# print $get_url,"\n";

# Make the request
my $res = $ua->request($req);
my $content = undef;
# Check the response
if ($res->is_success) {
    $content = $res->content;
} else {
    print $res->status_line . "\n";
}
# print $content;

my $num = 0;
#TODO make subfunctions
#initial landing pages
#TODO fix regex to ignore pics that is removed or in storage
my $issue_regex = qr/(?ms)class="details.+?href="([^"]*)/;  #rather stiff way of code

#article pagination extractor
my $pages_regex = qr/(?ms)class="number"(.+?)class="next/;
my $pages = undef;
($pages) = $content =~ m/$pages_regex/gm;

#add paginated pages' contents to first page's html content
if ( defined $pages ){
    # print "my pages: " . $pages . "\n";
    my $pagination_regex = qr/(?ms)href="([^"]*)/;
    while ( $pages =~ m/$pagination_regex/gm ){
        my $other_page_link = "http://www." . $username . $base_url . $1;
        print "other pages: " . $other_page_link,"\n";
        my $other_page = GET $other_page_link;
        my $other_page_content = $ua->request($other_page);

        if ($other_page_content->is_success) {
            $content .= $other_page_content->content;
        } else {
            print $other_page_content->status_line . "\n";
        }
    }
}

while ($content =~ m/$issue_regex/gm){
    ++$num;
    my $page_link = undef;
    $page_link = $1;

    my $image_page = GET $page_link;
    my $page_content = $ua->request($image_page);
    my $desc_content = undef;

    if ($page_content->is_success) {
        $desc_content = $page_content->content;
    } else {
        print $page_content->status_line . "\n";
    }
    # print $desc_content;

    #image link extractor
    my $image_regex = qr/(?ms)meta\sname="og\:image.+?"([^"]*)/;
    my $title_regex = qr/(?ms)meta\sname="og\:title.+?"([^"]*)/;
    my $description_regex = qr/(?ms)meta\sname="og\:description.+?"([^"]*)/;

    my $image_title = undef;
    ($image_title) = $desc_content =~ m/$title_regex/gm;
    my $image_link = undef;
    ($image_link) = $desc_content =~ m/$image_regex/gm;
    my $furl = (new URI::URL $image_link);
    my $filename = undef;
    $filename = $furl->path();
    $filename =~ s/.+?\///g;  #create image filename based on url
    $filename = "./images/" . $filename;
    # print "file name: " . $filename,"\n";
    getstore($furl, $filename);  #saves article images

    print "title: " . $image_title . "\n";
    
    # my $formatter = HTML::FormatText->new(leftmargin => 0, rightmargin => 50);
    # my $article_content_formatted = $formatter->format($html_tree);

    # print "article formatted: " . $article_content_formatted . "\n";
    print "\n";
}

print "total number: " . $num . "\n";

sub extract_content {
    my $html = shift;
    my $regex = shift;

    my $content = undef;
    ($content) = $html =~ m/$regex/gm;
    return $content;    
}

exit 0;