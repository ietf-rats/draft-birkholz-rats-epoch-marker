TEXT_PAGINATION := true
LIBDIR := lib
include $(LIBDIR)/main.mk

$(LIBDIR)/main.mk:
ifneq (,$(shell grep "path *= *$(LIBDIR)" .gitmodules 2>/dev/null))
	git submodule sync
	git submodule update --init
else
ifneq (,$(wildcard $(ID_TEMPLATE_HOME)))
	ln -s "$(ID_TEMPLATE_HOME)" $(LIBDIR)
else
	git clone -q --depth 10 -b main \
	    https://github.com/martinthomson/i-d-template $(LIBDIR)
endif
endif

include cddl/frag.mk

cddl/epoch-marker-autogen.cddl: $(addprefix cddl/,$(EPOCH_MARKER_FRAGS))
	$(MAKE) -C cddl check-epoch-marker check-epoch-marker-examples

cddl/examples/1.pretty:
	$(MAKE) -C cddl check-epoch-marker-examples

clean:: ; $(MAKE) -C cddl clean
