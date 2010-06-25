#
#  $Id$
#  
#  devbot
#  http://dev.stuconnolly.com/svn/devbot/
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

package DevBot::GCFeed;

use strict;
use warnings;

use XML::RSS;
use LWP::Simple;
use DevBot::Time;
use DevBot::Config;

use base 'Exporter';

our @EXPORT = qw(get_updated_issues);

our $VERSION = '1.0';

#
# Google Code hosting domain
#
our $GC_HOSTING_DOMAIN = 'code.google.com';
 
#
# Returns an array of updated issues.
#
sub get_updated_issues
{
	my $conf = get_config('gc');
	
	my $project = $conf->{GC_PROJECT};
	my $issue_url = $conf->{GC_ISSUE_URL};
	
	die 'No Google Code project name provided in Google Code config.' unless $project;
	
	my $min_datetime = get_last_updated_datetime;
	my $max_datetime = get_current_datetime;
	
	# If the datetimes are the same (ignoring seconds) then we've just been started so 
	# don't bother checking for updates.
	if (substr($min_datetime, -3) eq substr($max_datetime, -3)) {
		return;
	}
									
	my $xml = get("http://${GC_HOSTING_DOMAIN}/feeds/issues/p/${project}/issues/full?updated-min=${min_datetime}&updated-max=${max_datetime}&alt=rss&max-results=100000");		
		
	my $rss = new XML::RSS;
	
	$rss->parse($xml);
	
	my @issues = ();
	
	for my $item (@{$rss->{items}}) 
	{
		my $issue_id = _extract_issue_id($item->{link});
			
		my %issue = ('id'     => $issue_id,
					 'title'  => $item->{title},
					 'author' => $item->{author},
					 'url'    => _create_issue_url($project, $issue_url, $issue_id)
					);
				
		push(@issues, {%issue});
	}	
					
	return @issues;
}

#
# Extracts the issues ID from the supplied link.
#
sub _extract_issue_id
{
	my $issue_id  = 0; 
	my $issue_url = shift;
		
	if ($issue_url =~ /^http:\/\/${GC_HOSTING_DOMAIN}\/p\/[0-9a-z-]+\/issues\/detail\?id=([0-9]+)$/) {
		$issue_id = $1;
	}
	
	return $issue_id;
}

#
# Creates the URL for the supplied issue details.
#
sub _create_issue_url
{
	my($project, $issue_tracker, $issue_id) = @_;
	
	return ($issue_tracker) ? sprintf($issue_tracker, $issue_id) : sprintf("http://${GC_HOSTING_DOMAIN}/p/%s/issues/detail?id=%d", $project, $issue_id);
}

1;
