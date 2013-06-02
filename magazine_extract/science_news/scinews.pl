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
my $mag_issue_id = "8118";  #TODO how to convert month/year to id to simplify things
my $base_url = "sciencenews.org";
my $full_base_url = "http://www." . $base_url;
my $get_url = "http://www.sciencenews.org/view/issue/edition_id/" . $mag_issue_id;
my $req = GET $get_url; 
# my $req = POST 'http://www.sciencenews.org/index/issues', [ edition_id=>$mag_issue_id];  #TODO not working 

# Make the request
my $res = $ua->request($req);
my $content = undef;
# Check the response
if ($res->is_success) {
    $content = $res->content;
    #print $content;
} else {
    print $res->status_line . "\n";
}
# print $content;

my $num = 0;
#TODO make subfunctions
#initial landing page for a specific month issue
my $issue_regex = qr/(?ms)class="description\sprint.+?anonymous.+?href="([^"]*).+?>([^<]*)/;  #rather stiff way of code

while ($content =~ m/$issue_regex/gm){
    ++$num;
    my $article_link = undef;
    $article_link = $full_base_url . $1;  #tack on the base url
    my $title = $2;

    my $article_page = GET $article_link;
    my $page_content = $ua->request($article_page);
    my $desc_content = undef;

    if ($page_content->is_success) {
        $desc_content = $page_content->content;
    } else {
        print $page_content->status_line . "\n";
    }
    # print $desc_content;

    #article content extractor
    my $article_regex = qr/(?ms)class="article_title"(.+?)id="comments/;
    my ($article_content_raw) = $desc_content =~ m/$article_regex/gm;  #obtain first page's raw html contents

    #article image extractor
    my $html_tree = new HTML::TreeBuilder;
    $html_tree->parse($article_content_raw);
    foreach my $item (@{$html_tree->extract_links( "img" )}) {
        my $link = shift @$item;
        my $furl = (new URI::URL $link)->abs( $page_content->base );  #make sure to get the url that includes the base url
        if ($furl =~ /$base_url/){  #toss out junk images
            # print "image file url: " . $furl, "\n";
            my $filename = undef;
            $filename = $furl->path();  #TODO terrible inaccurate names
            $filename =~ s/.+?title\///g;  #create image filename based on url
            $filename = "./images/" . $filename . "\.jpg";  #TODO what if image is actually a gif instead of jpeg
            # print "file name: " . $filename,"\n";
            getstore($furl, $filename);  #saves article images
        }
    }

    print "title: " . $title . "\n";
    print "article link: " . $article_link . "\n";
    # print "preview: " . $preview . "\n";
    # print "author: " . $author ."\n";
    # print "article raw: " . $article_content_raw . "\n";
    
    # my $formatter = HTML::FormatText->new(leftmargin => 0, rightmargin => 50);
    # my $article_content_formatted = $formatter->format($html_tree);

    # print "article formatted: " . $article_content_formatted . "\n";
    print "\n";
    $html_tree->delete( );
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