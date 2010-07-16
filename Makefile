PACKAGE=rabbit_management
DEPS=rabbitmq-mochiweb rabbitmq-server rabbitmq-erlang-client
# NB: when rabbitmq-mochiweb depends on a newer version of mochiweb we can remove it as a dep here.
INTERNAL_DEPS=webmachine mochiweb-for-management
RUNTIME_DEPS=webmachine mochiweb-for-management

TEST_APPS=mochiweb-for-management rabbit_mochiweb rabbit_management
TEST_ARGS=-rabbit_mochiweb port 55672
START_RABBIT_IN_TESTS=true
EXTRA_PACKAGE_DIRS=priv

WEB_DIR=priv/www
JAVASCRIPT_DIR=$(WEB_DIR)/js
TEMPLATES_DIR=$(JAVASCRIPT_DIR)/tmpl
EXTRA_TARGETS=$(wildcard $(TEMPLATES_DIR)/*.ejs) \
    $(wildcard $(JAVASCRIPT_DIR)/*.js) \
    $(wildcard $(WEB_DIR)/*.html) \
    $(wildcard $(WEB_DIR)/css/*.css) \
    $(wildcard $(WEB_DIR)/img/*.png) \
    priv/dispatch.conf \

include ../include.mk
