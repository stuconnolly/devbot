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

use LWP::Simple;
use DevBot::Config;
use XML::RSS::Parser::Lite;

use base 'Exporter';

our @EXPORT = qw(get_gc_updated_issues);

our $VERSION = '1.0';

#
# 
#
use constant TIME_CHECK_FILE = '/tmp/devbot.tmp';
 
#
#
#
sub get_gc_updated_issues
{
	my $conf = get_config('gc');
	
	my $gc_project = $conf->{GC_PROJECT};
	
	die 'No Google Code project name provided in Google Code config.' unless $gc_project;
	
	my $xml = get("http://code.google.com/feeds/issues/p/${gc_project}/issues/full?updated-min=2010-05-23T00:00:00&updates-max=2010-05-23T18:59:59&alt=rss&max-results=100000&status=accepted,started,new");
	my $rp = new XML::RSS::Parser::Lite;
	
	$rp->parse($xml);

	for (my $i = 0; $i < $rp->count(); $i++) 
	{
		my $it = $rp->get($i);
		
		print $it->get('title') . " " . $it->get('url') . "\n";
	}
}

1;
