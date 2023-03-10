
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

LOG_INFO= '[$(build_mode)] [$(build_platform)]'

#

ifeq ($(build_platform),native)

DIR_LIB=		./lib/native

NAME_CRYPTOPP=	$(DIR_LIB)/lib-cryptopp.a

else ifeq ($(build_platform),web-wasm)

DIR_LIB=		./lib/web-wasm

NAME_CRYPTOPP=	$(DIR_LIB)/lib-cryptopp.bc

endif



#### DIRS

DIR_DEPENDENCIES=		./dependencies
DIR_CRYPTOPP_SRC=		$(DIR_DEPENDENCIES)/cryptopp

#### /DIRS



ifeq ($(build_platform),native)

DIR_OBJ=	./obj/native

else ifeq ($(build_platform),web-wasm)

DIR_OBJ=	./obj/web-wasm

endif

DIR_OBJ_CRYPTOPP=		$(DIR_OBJ)/cryptopp


#### SRC


SRC_CRYPTOPP+= \
	$(wildcard \
		$(DIR_CRYPTOPP_SRC)/*.cpp \
		)

#

OBJ_CRYPTOPP=	$(patsubst %.cpp, $(DIR_OBJ_CRYPTOPP)/%.o, $(SRC_CRYPTOPP))

#

#######


ifeq ($(build_mode),release)

BUILD_FLAG= -O3

else

BUILD_FLAG= -g3

endif



CXXFLAGS += $(BUILD_FLAG)
CXXFLAGS += -std=c++17
CXXFLAGS += -DCRYPTOPP_DISABLE_ASM
CXXFLAGS += -I$(DIR_CRYPTOPP_SRC)

LDFLAGS += -msse2
LDFLAGS += -msse3
LDFLAGS += -mssse3
LDFLAGS += -msse4.1
LDFLAGS += -msse4.2
LDFLAGS += -mpclmul
LDFLAGS += -maes
LDFLAGS += -mavx
LDFLAGS += -mavx2
LDFLAGS += -msha
LDFLAGS += -msimd128


ifeq ($(build_platform),native)

CXX=clang++
AR=ar

else ifeq ($(build_platform),web-wasm)

CXX=em++
AR=emar

endif


RM=			rm -rf


#######

#
## RULE(S)

all:	\
	libcryptopp

ensure_folders:
	@mkdir -p $(DIR_LIB)

libcryptopp: ensure_folders $(OBJ_CRYPTOPP)
	@echo ' ---> building $(LOG_INFO): "cryptopp library"'
	@$(AR) cr $(NAME_CRYPTOPP) $(OBJ_CRYPTOPP)
	@echo '   --> built $(LOG_INFO): "cryptopp library"'

#

# for every ".cpp" file
# => ensure the "obj" folder(s)
# => compile in a ".o" file

$(DIR_OBJ_CRYPTOPP)/%.o: %.cpp
	@mkdir -p $(dir $@)
	@echo ' --> processing $(LOG_INFO):' $<
	@$(CXX) $(CXXFLAGS) $< -c -o $@ $(LDFLAGS)

#

clean:
	@echo ' -> cleaning $(LOG_INFO): cryptopp library build file(s)'
	@$(RM) $(DIR_OBJ_CRYPTOPP)
	@echo '   -> cleaned $(LOG_INFO): cryptopp library build file(s)'

fclean: clean
	@echo ' -> cleaning $(LOG_INFO): cryptopp library file(s)'
	@$(RM) $(NAME_CRYPTOPP)
	@echo '   -> cleaned $(LOG_INFO): cryptopp library file(s)'

re:			fclean all

.PHONY:	\
		all \
		libcryptopp \
		clean \
		fclean \
		re

## RULE(S)
#
