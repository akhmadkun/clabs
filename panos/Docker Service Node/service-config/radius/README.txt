# Reference only: Debian's packaged FreeRADIUS instance uses
# /etc/freeradius/3.0/ for its main configuration.
#
# The universal image binds:
#   clients.conf -> /etc/freeradius/3.0/clients.conf
#   authorize    -> /etc/freeradius/3.0/mods-config/files/authorize
#
# For advanced labs, add site-specific listeners/modules under this directory.
