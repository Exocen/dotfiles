#!/bin/bash

#Fetch
echo "Fetching..."
# only for inbox
# docker exec -t mail_server doveadm fetch -A "user mailbox uid hdr.subject" mailbox INBOX savedbefore 20d
docker exec -t mail_server doveadm fetch -A "user mailbox uid hdr.subject" mailbox \* savedbefore 20d

#specific user
# docker exec -t mail_server doveadm fetch -A "user mailbox uid hdr.subject" -u "user@mail" mailbox \* savedbefore 20d

#Remove => switch fetch by expunge

# docker exec -t mail_server doveadm expunge -u "user@mail" -A mailbox TRASH savedbefore 20d
