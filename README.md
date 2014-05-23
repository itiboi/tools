Tools and Snippets
==================

This repo contains all useful tools and snippets I wrote over the time. Some are listed below with a short
description. For more detailed information take a look in the corresponding folders and files.

Everything in this repo is licenced under GPLv3.

CaCalUploader (Python)
----------------------

Handy script for RWTH Aachen University: It fetches all events of your CampusOffice calendar and uploads them to a
CalDAV calendar of your choice. It loads everything from a config file and can so easily be run as cron job.

Requires requests, icalendar, caldav.

Inspired by [Steffen Vogel's cocal script](https://github.com/stv0g/snippets/blob/master/php/campus/cocal.php).

gitbackup (Shell)
-----------------

Small script to backup and restore existing git repositories in one file with all unnecessary overhead stripped out.
Internally uses git bundle to backup.