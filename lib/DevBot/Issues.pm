#  
#  devbot
#  https://github.com/stuconnolly/devbot
#
#  Copyright (c) 2010 Stuart Connolly. All rights reserved.
# 
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

package DevBot::Issues;

use strict;
use warnings;

use Carp;
use XML::FeedPP;

use DevBot::Log;
use DevBot::Time;
use DevBot::Config;
use DevBot::Project;

use DateTime;
use DateTime::Format::W3CDTF;

our $VERSION = '1.00';

#
# Returns an array of updated issues via the project's issues Atom feed.
#
sub get_updated_issues
{
	my $feed;
	my @issues = ();
	
	my $project = DevBot::Project::name;
	my $domain = $DevBot::Project::GC_HOSTING_DOMAIN;
	
	croak 'No Google Code project name provided in Google Code config.' unless $project;
	
	my $url = "http://${domain}/feeds/p/${project}/issueupdates/basic";
						
	log_m("Requesting: $url", 'i');
	
	eval {
		$feed = XML::FeedPP::Atom->new($url);
	};
	
	if ($@) {
		chomp($@);
		log_m("Error retrieving feed: $@", 'i');
	}
	else {
		my $w3c = DateTime::Format::W3CDTF->new;

		my $pub_date = $feed->pubDate();

		# Remove timezone indicator
		$pub_date =~ s/Z//g;

		my $cur_datetime = $w3c->parse_datetime(get_last_updated_datetime);	
		my $feed_datetime = $w3c->parse_datetime($pub_date);

		write_datetime($feed_datetime); 

		# Only continue if the feed's publication date is newer than the last time we checked it
		if (DateTime->compare($feed_datetime, $cur_datetime) > 0) {

			foreach my $item ($feed->get_item()) 
			{	
				my $item_datetime = $w3c->parse_datetime($item->pubDate());	

				# Remove timezone indicator
				$item_datetime =~ s/Z//g;

				if (DateTime->compare($item_datetime, $cur_datetime) > 0) {

					my %ids = _extract_ids($item->link());

					my $url;
					my $issue_id = {%ids}->{issue_id};

					if ($issue_id > 0) {
						$url = DevBot::Project::create_issue_url($issue_id, {%ids}->{comment_id});
					}

					my %issue = (id     => $issue_id,
								 title  => $item->title(),
								 author => $item->author(),
								 url    => $url
								);

					push(@issues, {%issue});
				}
			}
		}

		# Reverse the array so we report the updates in the order they occurred, 
		# not the order we encountered them.
		@issues = reverse(@issues);

		my $issue_count = @issues;

		log_m(sprintf('Found %d issue updates', $issue_count), 'i');
	}
	
	return @issues;
}

#
# Extracts the issues ID from the supplied link.
#
sub _extract_ids
{
	my $issue_id   = 0;
	my $comment_id = 0;
	 
	my $issue_url = shift;
	
	my $domain = $DevBot::Project::GC_HOSTING_DOMAIN;
		
	($issue_url =~ /^http:\/\/${domain}\/p\/[0-9a-z-]+\/issues\/detail\?id=([0-9]+)(?:#c([0-9]+))?$/) && ($issue_id = $1, $comment_id = $2);
		
	return (issue_id => $issue_id, comment_id => $comment_id);
}

1;
