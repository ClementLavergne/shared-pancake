# Get current working directory
ifeq ($(OS),Windows_NT)
	ROOT_PATH 			:= $(PWD)
else
	ROOT_PATH 			:= $(shell pwd)
endif

# Command-line argument
PRJ_PATH			?= $(ROOT_PATH)/example
OUT_PATH 		   	?= $(PRJ_PATH)/generated
SRC_FILE 			?= source/tutorial-custom.yml

# Project configuration
FILTER_DIR 			:= script
TMP_DIR				:= tmp
METADATA_DEPS_STR	:= template "highlight-style" "reference-doc"
METADATA_DEPS_ARRAY	:= "input-files" "metadata-files" css filters

# Variables
SRC_NAME 			= $(basename $(notdir $(SRC_FILE)))

# Common Pandoc arguments
COMMON_ARGS 		:= 	--from markdown \
						--defaults $(PRJ_PATH)/$(SRC_FILE) \
						--lua-filter $(ROOT_PATH)/$(FILTER_DIR)/metadata-fill/metadata-fill.lua \
						--lua-filter $(ROOT_PATH)/$(FILTER_DIR)/bottom-content/bottom-content.lua \
						--lua-filter $(ROOT_PATH)/$(FILTER_DIR)/next-page/next-page.lua \
						$(ROOT_PATH)/markdown/bottom.md

export ROOT_PATH
export SRC_NAME
export OUT_PATH
export TMP_DIR

#############
# Functions #
#############
# 1: YAML file
# 2: key
extract_string_from_yaml 	= $(shell ruby -rjson -ryaml -e "puts JSON.pretty_generate(YAML.load_file('$(1)'))" | jq -r 'select(.$(2) != null) | .$(2)')
extract_array_from_yaml 	= $(shell ruby -rjson -ryaml -e "puts JSON.pretty_generate(YAML.load_file('$(1)'))" | jq -r 'select(.$(2) != null) | .$(2) | join(" ")')
extract_keys_from_yaml 		= $(shell ruby -rjson -ryaml -e "puts JSON.pretty_generate(YAML.load_file('$(1)'))" | jq -r 'select(.$(2) != null) | .$(2) | keys | join(" ")')
# 1: YAML file
# 2: string keys
get_string_deps				= $(foreach key,$(2),$(addprefix $(PRJ_PATH)/,$(call extract_string_from_yaml,$(1),$(key))))
# 1: YAML file
# 2: array keys
get_array_deps 				= $(foreach key,$(2),$(addprefix $(PRJ_PATH)/,$(call extract_array_from_yaml,$(1),$(key))))

#########
# Rules #
#########
include $(OUT_PATH)/$(TMP_DIR)/$(SRC_NAME)/$(SRC_NAME).mk

define BASE
# Generic rules
.DEFAULT_GOAL 	:= 	all
.PHONY:             all $(markup_formats) clean $(clean_targets) clean-all

all:    $(markup_formats)

clean:  $(clean_targets)
	rm -r $(OUT_PATH)/$(TMP_DIR)/$(SRC_NAME)
endef

define RULES
# '$(markup)' rules
$(markup):	$(OUT_PATH)/$(filename).$(markup)

clean-$(markup):
	@echo "- $(SRC_NAME): clean '$(markup)' generated files"
	rm $(OUT_PATH)/$(filename).$(markup)

$(OUT_PATH)/$(filename).$(markup): 	$(PRJ_PATH)/$(SRC_FILE) $($(markup)-recipe) $($(markup)-deps) $(deps)
	@echo "- $(SRC_NAME): generate '$(filename).$(markup)'"
	cd $(PRJ_PATH); pandoc --defaults $($(markup)-recipe) $(COMMON_ARGS) --output $(OUT_PATH)/$(filename).$(markup)
	@echo "- $(SRC_NAME): '$(filename).$(markup)' successfully generated!"
endef

$(OUT_PATH)/$(TMP_DIR)/$(SRC_NAME):
	@echo "- $(SRC_NAME): create folder '$@':"
	mkdir -p $@

$(OUT_PATH)/$(TMP_DIR)/$(SRC_NAME)/$(SRC_NAME).mk:	$(eval markup_formats = $(call extract_keys_from_yaml,$(PRJ_PATH)/$(SRC_FILE),metadata.targets))
$(OUT_PATH)/$(TMP_DIR)/$(SRC_NAME)/$(SRC_NAME).mk:	$(eval clean_targets  = $(addprefix clean-, $(markup_formats)))
$(OUT_PATH)/$(TMP_DIR)/$(SRC_NAME)/$(SRC_NAME).mk: 	$(PRJ_PATH)/$(SRC_FILE) \
													| $(OUT_PATH)/$(TMP_DIR)/$(SRC_NAME)
	@echo "- $(SRC_NAME): generate '$@'"
	$(eval src_version = $(call extract_string_from_yaml,$<,metadata.version))
	$(eval filename = $(if $(src_version),$(SRC_NAME)-$(src_version),$(SRC_NAME)))
	$(foreach markup,$(markup_formats),$(eval $(markup)-recipe = $(call get_string_deps,$<,metadata.targets.$(markup))))
	$(eval deps = $(call get_string_deps,$<,$(METADATA_DEPS_STR)))
	$(eval deps += $(call get_array_deps,$<,$(METADATA_DEPS_ARRAY)))
	$(foreach markup,$(markup_formats),$(eval $(markup)-deps = $(call get_string_deps,$($(markup)-recipe),$(METADATA_DEPS_STR))))
	$(foreach markup,$(markup_formats),$(eval $(markup)-deps += $(call get_array_deps,$($(markup)-recipe),$(METADATA_DEPS_ARRAY))))
	$(file > $@,$(BASE))
	$(file >> $@,)
	$(foreach markup,$(markup_formats),$(file >> $@,$(RULES)))

clean-all:
	rm -r $(OUT_PATH)