## 
## Build dero packages
## ------------------
## 

OS=linux
# amd64,386,arm5,arm6,arm7
ARCHITECTURE=amd64
FPM_BIN=~/.gem/ruby/2.6.0/bin/fpm

TARDIR=dero_$(OS)_$(ARCHITECTURE)
TARBALL=$(TARDIR).tar.gz

# mainet
VERSION=2.1.6
ITERATION=3
DOWNLOAD=http://seeds.dero.io/atlantis/$(TARBALL)
STATS_DL=https://github.com/deroproject/dero-network-stats/blob/master/build/stats-client-linux?raw=true

DEPENDENCIES := tmux

#--------------- Dont edit behind this line -----------------------

SERVICE_DIR=/lib/systemd/system/
LOG_DIR=/var/log/dero
BIN_DIR=/usr/sbin
DATA_DIR=/var/lib
CONF_DIR=/etc
LOGROTATE_DIR=/etc/logrotate.d

OUTPUT_DIR=deb
BUILD_DIR=deb-src
TMPL_DIR=templates

.PHONY: default
default: help

$(TARBALL):
	wget $(DOWNLOAD)

$(TARDIR): $(TARBALL)
	tar -zxf $(TARBALL)

define gen_derod_src
	mkdir -p $(BUILD_DIR)$(DATA_DIR)
	mkdir -p $(BUILD_DIR)$(BIN_DIR)
	mkdir -p $(BUILD_DIR)$(SERVICE_DIR)
	mkdir -p $(BUILD_DIR)$(CONF_DIR)
	mkdir -p $(BUILD_DIR)$(LOGROTATE_DIR)
	mkdir -p $(BUILD_DIR)$(LOG_DIR)
	cp  $(TARDIR)/derod-$(OS)-$(ARCHITECTURE) $(BUILD_DIR)$(BIN_DIR)/derod
	chmod +x $(BUILD_DIR)$(BIN_DIR)/derod
	sed -e 's?%CONF_DIR%?$(CONF_DIR)?g' \
			-e 's?%WORKING_DIR%?$(LOG_DIR)?g' \
			-e 's?%BIN_DIR%?$(BIN_DIR)?g' \
			-e 's?%DATA_DIR%?$(DATA_DIR)?g' \
			$(TMPL_DIR)/derod.service > $(BUILD_DIR)$(SERVICE_DIR)/derod.service
	cp $(TMPL_DIR)/dero.conf $(BUILD_DIR)$(CONF_DIR)/dero.conf
	sed -e 's?%LOG_DIR%?$(LOG_DIR)?g' \
			$(TMPL_DIR)/derod.logrotate >  $(BUILD_DIR)$(LOGROTATE_DIR)/derod
	cp $(TMPL_DIR)/derod-cli $(BUILD_DIR)$(BIN_DIR)/derod-cli
	chmod +x $(BUILD_DIR)$(BIN_DIR)/derod-cli
	sed	-e 's?%DATA_DIR%?$(DATA_DIR)?g' \
			$(TMPL_DIR)/derod-init-db > $(BUILD_DIR)$(BIN_DIR)/derod-init-db
	chmod +x $(BUILD_DIR)$(BIN_DIR)/derod-init-db
endef

define gen_explorer_src
	mkdir -p $(BUILD_DIR)$(BIN_DIR)
	mkdir -p $(BUILD_DIR)$(SERVICE_DIR)
	mkdir -p $(BUILD_DIR)$(CONF_DIR)
	cp  $(TARDIR)/explorer-$(OS)-$(ARCHITECTURE) $(BUILD_DIR)$(BIN_DIR)/dero-explorer
	chmod +x $(BUILD_DIR)$(BIN_DIR)/dero-explorer
	sed -e 's?%CONF_DIR%?$(CONF_DIR)?g' \
			-e 's?%WORKING_DIR%?$(LOG_DIR)?g' \
			-e 's?%BIN_DIR%?$(BIN_DIR)?g' \
			$(TMPL_DIR)/dero-explorer.service > $(BUILD_DIR)$(SERVICE_DIR)/dero-explorer.service
endef

define gen_client_src
	mkdir -p $(BUILD_DIR)$(BIN_DIR)
	cp  $(TARDIR)/dero-wallet-cli-$(OS)-$(ARCHITECTURE) $(BUILD_DIR)$(BIN_DIR)/dero-wallet-cli
	chmod +x $(BUILD_DIR)$(BIN_DIR)/dero-wallet-cli
endef

define gen_statsclient_src
	mkdir -p $(BUILD_DIR)$(BIN_DIR)
	mkdir -p $(BUILD_DIR)$(SERVICE_DIR)
	wget $(STATS_DL) -O $(BUILD_DIR)$(BIN_DIR)/dero-stats-client
	chmod +x $(BUILD_DIR)$(BIN_DIR)/dero-stats-client
	sed -e 's?%CONF_DIR%?$(CONF_DIR)?g' \
			-e 's?%WORKING_DIR%?/tmp?g' \
			-e 's?%BIN_DIR%?$(BIN_DIR)?g' \
			$(TMPL_DIR)/dero-stats-client.service > $(BUILD_DIR)$(SERVICE_DIR)/dero-stats-client.service
	sed -e 's?%CONF_DIR%?$(CONF_DIR)?g' \
			-e 's?%WORKING_DIR%?/tmp?g' \
			$(TMPL_DIR)/dero-stats-config > $(BUILD_DIR)$(BIN_DIR)/dero-stats-config
	chmod +x $(BUILD_DIR)$(BIN_DIR)/dero-stats-config
endef

.PHONY: deb
deb: ## Create deb packages (ubuntu, debian)
deb: $(TARDIR)
	mkdir -p $@ 
# make derod deb
	mkdir -p $(BUILD_DIR)
	$(call gen_derod_src)
	$(FPM_BIN) -f -p $@ -s dir -t deb -v $(VERSION) --iteration $(ITERATION) -n derod $(foreach dep,$(DEPENDENCIES),-d $(dep)) -a $(ARCHITECTURE) -C $(BUILD_DIR) . 
	rm -rf $(BUILD_DIR)
# make dero-explorer deb
	mkdir -p $(BUILD_DIR)
	$(call gen_explorer_src)
	$(FPM_BIN) -f -p $@ -s dir -t deb -v $(VERSION) --iteration $(ITERATION) -n dero-explorer -d derod -a $(ARCHITECTURE) -C $(BUILD_DIR) . 
	rm -rf $(BUILD_DIR)
# make dero-explorer deb
	mkdir -p $(BUILD_DIR)
	$(call gen_client_src)
	$(FPM_BIN) -f -p $@ -s dir -t deb -v $(VERSION) --iteration $(ITERATION) -n dero-wallet-cli -a $(ARCHITECTURE) -C $(BUILD_DIR) . 
	rm -rf $(BUILD_DIR)
# make dero-stats-client deb
	mkdir -p $(BUILD_DIR)
	$(call gen_statsclient_src)
	$(FPM_BIN) -f -p $@ -s dir -t deb -v $(VERSION) --iteration $(ITERATION) -n dero-stats-client -d derod -a $(ARCHITECTURE) -C $(BUILD_DIR) . 
	rm -rf $(BUILD_DIR)


.PHONY: clean
clean: ## Clean all
clean:
	rm -rf deb
	rm -rf $(TARBALL)
	rm -rf $(TARDIR) 
	rm -rf $(BUILD_DIR) 
.PHONY: help

help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
