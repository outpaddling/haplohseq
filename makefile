# Makefile for 'haplohseq'

**** MAKING EXECUTABLE:
# (1) make clean (optional)
# (2) make test (optional)
# (3) make haplohseq
#

# Constants
# Default to g++ if not set by make args or environment
CXX?=g++
#-O0 -g will turn on debugging
#The rule of thumb:
#When you need to debug, use -O0 (and -g to generate debugging symbols.)
#When you are preparing to ship it, use -O2.
#When you use gentoo, use -O3...!
#When you need to put it on an embedded system, use -Os (optimize for size, not for efficiency.)
# Use canonincal compiler variables, which may be provided by build env
CXXFLAGS?=-Wall -g -stdlib=libstdc++
SRC=src
CONF=conf
HMM_SRC=$(SRC)/hmm
UTIL_SRC=$(SRC)/util
BOOST?=/usr/local/boost_1_52_0
INCLUDES=-I./$(SRC) -I./$(HMM_SRC) -I./$(UTIL_SRC) -isystem$(BOOST)
LIBRARY_PATHS?=-Llib/macosx
LIBRARIES=-lm -lboost_program_options -lboost_system -lboost_filesystem -lboost_thread

# Installation target with destdir support
DESTDIR?=.
PREFIX?=/usr/local
MKDIR?=mkdir
INSTALL?=install
STRIP?= # empty, set to -s to install stripped binary

# Generated directories which are generated in this script and cleaned up with 'make clean'
BUILD=build
OBJ=$(BUILD)/obj
BIN=$(BUILD)/bin

# Create needed directories if they don't exist
directories:
	mkdir -p $(BUILD) $(BIN) $(OBJ)

# Create object files into the OBJ directory from cpp files in the SRC directory.
$(OBJ)/%.o:	$(SRC)/%.cpp directories
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<
$(OBJ)/%.o:	$(HMM_SRC)/%.cpp directories
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<
$(OBJ)/%.o:	$(UTIL_SRC)/%.cpp directories
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

all: haplohseq test

haplohseq: $(OBJ)/Hmm.o $(OBJ)/DataStructures.o $(OBJ)/MathUtil.o $(OBJ)/StringUtil.o $(OBJ)/InputProcessor.o $(OBJ)/Reporter.o $(OBJ)/FreqPhase.o $(OBJ)/VcfUtil.o $(OBJ)/HaplohSeq.o
	$(CXX) -o $(BIN)/$@ $(CXXFLAGS) $(INCLUDES) $(OBJ)/Hmm.o $(OBJ)/DataStructures.o $(OBJ)/MathUtil.o $(OBJ)/StringUtil.o $(OBJ)/InputProcessor.o $(OBJ)/Reporter.o $(OBJ)/FreqPhase.o $(OBJ)/VcfUtil.o $(OBJ)/HaplohSeq.o $(LIBRARY_PATHS) $(LIBRARIES) $(LDFLAGS)

install:
	$(MKDIR) -p $(DESTDIR)$(PREFIX)/bin
	$(INSTALL) -c $(STRIP) $(BIN)/* $(DESTDIR)$(PREFIX)/bin

clean:
	rm -rf $(BUILD)

############################## BEGIN TEST LOGIC ##############################
TEST_SRC=$(SRC)/test
TEST_RESOURCES=$(TEST_SRC)/resources
TEST_INCLUDES=-isystem$(BOOST)
TEST_LIBRARIES=-lcpptest
TEST_BIN=$(BUILD)/test
TEST_LOG_LEVEL=--log_level=all
# all, warning, error

test_directory:
	mkdir -p $(TEST_BIN)
	cp -r $(TEST_RESOURCES) $(TEST_BIN)
	
# This will make all executables	
test: FreqPhaseTest HaplohSeqTest HmmTest InputProcessorTest
#	cd $(TEST_BIN); ./HaplohSeqTest $(TEST_LOG_LEVEL)
#	cd $(TEST_BIN); ./FreqPhaseTest $(TEST_LOG_LEVEL)
#	cd $(TEST_BIN); ./HmmTest $(TEST_LOG_LEVEL)
#	cd $(TEST_BIN); ./InputProcessorTest $(TEST_LOG_LEVEL)
#	cd $(TEST_BIN); ./MathUtilTest $(TEST_LOG_LEVEL)
#	cd $(TEST_BIN); ./OutputProcessorTest $(TEST_LOG_LEVEL)

# Create test object files into the OBJ directory from cpp files in the SRC directory.
$(TEST_BIN)/%.o:	$(TEST_SRC)/%.cpp directories test_directory
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(TEST_INCLUDES) -c -o $@ $<

HaplohSeqTest:	$(OBJ)/Hmm.o $(OBJ)/DataStructures.o $(OBJ)/MathUtil.o $(OBJ)/StringUtil.o $(OBJ)/InputProcessor.o $(TEST_BIN)/HaplohSeqTest.o
	$(CXX) -o $(TEST_BIN)/$@ $(CXXFLAGS) $(OBJ)/Hmm.o $(OBJ)/DataStructures.o $(OBJ)/MathUtil.o $(OBJ)/StringUtil.o $(OBJ)/InputProcessor.o $(TEST_BIN)/HaplohSeqTest.o $(LIBRARY_PATHS) $(LIBRARIES) $(LDFLAGS)

FreqPhaseTest:	$(OBJ)/StringUtil.o $(OBJ)/InputProcessor.o $(OBJ)/FreqPhase.o $(TEST_BIN)/FreqPhaseTest.o
	$(CXX) -o $(TEST_BIN)/$@ $(CXXFLAGS) $(OBJ)/StringUtil.o $(OBJ)/InputProcessor.o $(OBJ)/FreqPhase.o $(TEST_BIN)/FreqPhaseTest.o $(LIBRARY_PATHS) $(LIBRARIES) $(LDFLAGS)

HmmTest:	$(OBJ)/Hmm.o $(OBJ)/DataStructures.o $(OBJ)/MathUtil.o $(OBJ)/StringUtil.o $(TEST_BIN)/HmmTest.o
	$(CXX) -o $(TEST_BIN)/$@ $(CXXFLAGS) $(OBJ)/Hmm.o $(OBJ)/DataStructures.o $(OBJ)/MathUtil.o $(OBJ)/StringUtil.o $(TEST_BIN)/HmmTest.o $(LIBRARY_PATHS) $(LIBRARIES) $(LDFLAGS)

InputProcessorTest:	$(OBJ)/Hmm.o $(OBJ)/DataStructures.o $(OBJ)/MathUtil.o $(OBJ)/StringUtil.o $(OBJ)/InputProcessor.o $(TEST_BIN)/InputProcessorTest.o
	$(CXX) -o $(TEST_BIN)/$@ $(CXXFLAGS) $(OBJ)/Hmm.o $(OBJ)/DataStructures.o $(OBJ)/MathUtil.o $(OBJ)/StringUtil.o $(OBJ)/InputProcessor.o $(TEST_BIN)/InputProcessorTest.o $(LIBRARY_PATHS) $(LIBRARIES) $(LDFLAGS)
	
MathUtilTest:	$(OBJ)/Hmm.o $(OBJ)/DataStructures.o $(OBJ)/MathUtil.o $(OBJ)/StringUtil.o $(TEST_BIN)/MathUtilTest.o
	$(CXX) -o $(TEST_BIN)/$@ $(CXXFLAGS) $(OBJ)/Hmm.o $(OBJ)/DataStructures.o $(OBJ)/MathUtil.o $(OBJ)/StringUtil.o $(TEST_BIN)/MathUtilTest.o $(LIBRARY_PATHS) $(LIBRARIES) $(LDFLAGS)
	
ReporterTest:	$(OBJ)/Hmm.o $(OBJ)/DataStructures.o $(OBJ)/MathUtil.o $(OBJ)/StringUtil.o $(TEST_BIN)/ReporterTest.o
	$(CXX) -o $(TEST_BIN)/$@ $(CXXFLAGS) $(OBJ)/Hmm.o $(OBJ)/DataStructures.o $(OBJ)/MathUtil.o $(OBJ)/StringUtil.o $(TEST_BIN)/ReporterTest.o $(LIBRARY_PATHS) $(LIBRARIES) $(LDFLAGS)

ThreadPoolTest:	$(OBJ)/Hmm.o $(OBJ)/DataStructures.o $(OBJ)/MathUtil.o $(OBJ)/StringUtil.o $(OBJ)/ThreadPool.o $(TEST_BIN)/ThreadPoolTest.o
	$(CXX) -o $(TEST_BIN)/$@ $(CXXFLAGS) $(OBJ)/Hmm.o $(OBJ)/DataStructures.o $(OBJ)/MathUtil.o $(OBJ)/StringUtil.o $(OBJ)/ThreadPool.o $(TEST_BIN)/ThreadPoolTest.o $(LIBRARY_PATHS) $(LIBRARIES) $(LDFLAGS)
############################## END TEST LOGIC ##############################



