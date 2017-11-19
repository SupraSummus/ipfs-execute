DESTDIR       =
PREFIX        = /usr/local
INSTALL       = /usr/bin/env install
bindir        = $(PREFIX)/bin

install: $(SCRIPTS)
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(INSTALL) -m755 ipfs_execute.sh $(DESTDIR)$(bindir)/ipfs-execute
