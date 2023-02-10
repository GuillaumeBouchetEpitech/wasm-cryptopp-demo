
build_platform=native
# build_platform=web-wasm

build_mode=release
# build_mode=debug

#

ifeq ($(build_platform),native)
# $(info build_platform is valid, value=$(build_platform))
else ifeq ($(build_platform),web-wasm)
# $(info build_platform is valid, value=$(build_platform))
else
$(error unsupported value for "build_platform", value=$(build_platform))
endif

#

ifeq ($(build_mode),release)
# $(info build_mode is valid, value=$(build_mode))
else ifeq ($(build_mode),debug)
# $(info build_mode is valid, value=$(build_mode))
else
$(error unsupported value for "build_mode", value=$(build_mode))
endif

LOG_INFO= '[$(build_mode)] [$(build_platform)]'

#

ifeq ($(build_platform),native)

DIR_TARGET=					./bin
NAME_APPLICATION=		$(DIR_TARGET)/exec

else ifeq ($(build_platform),web-wasm)

DIR_TARGET=					./dist/web-wasm
NAME_APPLICATION=		$(DIR_TARGET)/index.js

endif

#

DIR_LIB_CRYPTOPP=	./thirdparties/dependencies/cryptopp


ifeq ($(build_platform),native)

NAME_LIB_CRYPTOPP=	./thirdparties/lib/native/lib-cryptopp.a

else

NAME_LIB_CRYPTOPP=	./thirdparties/lib/web-wasm/lib-cryptopp.bc

endif



#### DIRS

DIR_SRC=														./src

#### /DIRS



ifeq ($(build_platform),native)

DIR_OBJ=									./obj/native

else

ifeq ($(build_platform),web-wasm)

DIR_OBJ=									./obj/web-wasm

endif

endif

#### SRC

SRC+=	\
	$(wildcard \
		$(DIR_SRC)/*.cpp \
		)

#

OBJ=	$(patsubst %.cpp, $(DIR_OBJ)/%.o, $(SRC))

#######


ifeq ($(build_mode),release)

BUILD_FLAG=		-O3 # optimisation flag

else

BUILD_FLAG=		-g3 # debug flag

endif

CXXFLAGS += $(BUILD_FLAG)
CXXFLAGS += -std=c++17
CXXFLAGS += -Wall -W -Wextra -Wunused
CXXFLAGS += -I$(DIR_SRC)
CXXFLAGS += -I$(DIR_LIB_CRYPTOPP)



ifeq ($(build_platform),native)

CXX=clang++
AR=ar

CXXFLAGS += $(DEPENDENCIES_CXXFLAGS)

LDFLAGS += $(BUILD_FLAG)
LDFLAGS += $(NAME_LIB_CRYPTOPP)

else

CXX=em++
AR=emar

LDFLAGS_COMMON_WEB_WASM += -s TOTAL_MEMORY=128Mb # 16Kb, 256Mb, etc.
LDFLAGS_COMMON_WEB_WASM += -s WASM=1
LDFLAGS_COMMON_WEB_WASM += -s BINARYEN_IGNORE_IMPLICIT_TRAPS=1
LDFLAGS_COMMON_WEB_WASM += -s DISABLE_DEPRECATED_FIND_EVENT_TARGET_BEHAVIOR=0

LDFLAGS_COMMON_WEB_WASM += -s EXPORTED_FUNCTIONS="['_free']"
LDFLAGS_COMMON_WEB_WASM += -s EXPORTED_RUNTIME_METHODS="['cwrap','_malloc','stringToUTF8','lengthBytesUTF8','UTF8ToString']"

LDFLAGS += $(BUILD_FLAG)
LDFLAGS += $(FLAGS_WEB_WASM_MAIN)
LDFLAGS += $(NAME_LIB_CRYPTOPP)
LDFLAGS += $(LDFLAGS_COMMON_WEB_WASM)

endif


RM=			rm -rf


#######

#
## RULE(S)

all:	application

ensurefolders:
	@mkdir -p `dirname $(NAME_APPLICATION)`

application:	ensurefolders $(OBJ)
	@echo ' ---> building $(LOG_INFO): "application"'
	@$(CXX) $(CXXFLAGS) $(OBJ) -o $(NAME_APPLICATION) $(LDFLAGS)
	@echo '   --> built $(LOG_INFO): "application"'

#

# for every ".cpp" file
# => ensure the "obj" folder(s)
# => compile in a ".o" file

$(DIR_OBJ)/%.o: %.cpp
	@mkdir -p $(dir $@)
	@echo ' ---> processing $(LOG_INFO):' $<
	$(CXX) -c $(CXXFLAGS) -MMD -MT "$@" -MF "$@.dep" -o "$@" $<

include $(shell test -d $(DIR_OBJ) && find $(DIR_OBJ) -name "*.dep")

#

clean:
	@echo ' -> cleaning $(LOG_INFO): application build file(s)'
	$(RM) $(DIR_OBJ)
	@echo '   -> cleaned $(LOG_INFO): application build file(s)'

fclean:	clean
	@echo ' -> cleaning $(LOG_INFO): application file(s)'
	$(RM) $(NAME_APPLICATION)
	@echo '   -> cleaned $(LOG_INFO): application file(s)'

re:		fclean all

.PHONY: \
	all \
	application \
	clean \
	fclean \
	re

## RULE(S)
#
