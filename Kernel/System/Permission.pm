# --
# Permission.pm - to control the access permissions 
# Copyright (C) 2001-2002 Martin Edenhofer <martin+code@otrs.org>
# --
# $Id: Permission.pm,v 1.2 2002-04-13 15:47:16 martin Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl.txt.
# --

package Kernel::System::Permission;

use strict;

use vars qw($VERSION);
$VERSION = '$Revision: 1.2 $';
$VERSION =~ s/^.*:\s(\d+\.\d+)\s.*$/$1/;

# --
sub new {
    my $Type = shift;
    my %Param = @_;

    # allocate new hash for object
    my $Self = {}; 
    bless ($Self, $Type);

    foreach (keys %Param) {
        $Self->{$_} = $Param{$_};
    }

    # check needed Opjects
    foreach ('DBObject', 'LogObject', 'UserObject', 'QueueObject') {
        die "Got no $_!" if (!$Self->{$_});
    }

    $Self->{DBObject} = $Param{DBObject};

    # all sections <-> groups   
    $Self->{PermissionAdmin}   = 'admin';
    $Self->{PermissionAgent}   = 'users';

    return $Self;
}
# --
sub Section {
    my $Self = shift;
    my %Param = @_;
    my $UserID = $Param{UserID} || return;
    my $Section = 'Permission' . $Param{Section};

    my %Groups = $Self->{UserObject}->GetGroups(UserID => $UserID);
    foreach (keys %Groups) {
        if ($Groups{$_} eq $Self->{$Section}) {
            return 1;
        }
    }
    return;
}
# --
sub Ticket {
    my $Self = shift;
    my %Param = @_;
    my $TicketID = $Param{TicketID} || return;
    my $UserID = $Param{UserID} || return;
    my $QueueID = $Self->{TicketObject}->GetQueueIDOfTicketID(TicketID => $TicketID);
    my $GID = $Self->{QueueObject}->GetQueueGroupID(QueueID => $QueueID);
    my %Groups = $Self->{UserObject}->GetGroups(UserID => $UserID);
    foreach (keys %Groups) {
        if ($_ eq $GID) {
            return 1;
        }
    }
    return;
}
# --

1;
