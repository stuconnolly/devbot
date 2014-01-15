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

package DevBot::Queries;

use strict;
use warnings;

our $VERSION = '1.00';

#
# History query.
#
our $HISTORY_QUERY = 
	"SELECT FROM_UNIXTIME(TIMESTAMP, '%H:%i:%S UTC'), nick, line 
	 FROM  irclog
	 WHERE channel      = ?
	 AND   LENGTH(nick) > 0 
	 AND   SUBSTRING(nick FROM 1 FOR 3) != 'CIA'
	 ORDER BY `timestamp` DESC 
	 LIMIT ?";

1;
