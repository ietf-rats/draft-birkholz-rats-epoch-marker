TEXT_PAGINATION := true
LIBDIR := lib
include $(LIBDIR)/main.mk

$(LIBDIR)/main.mk:
ifneq (,$(shell grep "path *= *$(LIBDIR)" .gitmodules 2>/dev/null))
	git submodule sync
	git submodule update $(CLONE_ARGS) --init
else
	git clone -q --depth 10 $(CLONE_ARGS) \
	    -b main https://github.com/martinthomson/i-d-template $(LIBDIR)
endif

include cddl/frag.mk

# $(drafts_xml):: cddl/epoch-marker-autogen.cddl

cddl/epoch-marker-autogen.cddl: $(addprefix cddl/,$(EPOCH_MARKER_FRAGS))
	$(MAKE) -C cddl check-epoch-marker check-epoch-marker-examples

clean:: ; $(MAKE) -C cddl clean
