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

package DevBot::GitHub::Issues;

use strict;
use warnings;

use Carp;
use Net::GitHub;

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
}

#
# Extracts the issues ID from the supplied link.
#
sub _extract_ids
{
}

1;
