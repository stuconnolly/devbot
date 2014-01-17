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

package t::Config;

use strict;
use warnings;

use Test::More;

use base 'Test::Class';

BEGIN
{
	use_ok('DevBot::Time');
}

sub test_gmt_date : Test
{
	my @day = gmtime(time);
    
	my $epxected = sprintf('%04d-%02d-%02d', $day[5] + 1900, $day[4] + 1, $day[3]);

	is(DevBot::Time::gmt_date(), $epxected, 'GMT date is correct');
}

1;