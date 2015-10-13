CXX := g++
CXXFLAGS := -std=c++11 -msse4.2
LDFLAGS := -stdlib=libc++

INPUT := ../input.txt

BINDIR = bin
SRCDIR := src
TESTDIR := tests
BUILDDIR := build
INC := -I include
LIB := -L lib

ALL_SOURCES := $(wildcard $(SRCDIR)/*.cpp)

RUN_SOURCES := $(wildcard $(SRCDIR)/*_main.cpp)
RUN_OBJECTS := $(patsubst %,$(BUILDDIR)/%,$(RUN_SOURCES:.cpp=.o))
RUN_TARGETS := $(patsubst $(BUILDDIR)/%,$(BINDIR)/%,$(RUN_OBJECTS))

TEST_SOURCES := $(wildcard $(TESTDIR)/test_*.cpp)
TEST_OBJECTS := $(patsubst %,$(BUILDDIR)/%,$(TEST_SOURCES:.cpp=.o))
TEST_TARGETS := $(patsubst $(BUILDDIR)/%,$(BINDIR)/%,$(TEST_OBJECTS))

SOURCES := $(filter-out $(RUN_SOURCES),$(ALL_SOURCES))
OBJECTS := $(patsubst %,$(BUILDDIR)/%,$(SOURCES:.cpp=.o))

.PHONY: clean test run

.SECONDARY: $(RUN_OBJECTS) $(TEST_OBJECTS) $(OBJECTS)

clean:
	rm -rf $(BINDIR)/ $(BUILDDIR)/

$(BUILDDIR) $(BINDIR):
	mkdir -p $@
	mkdir -p $@/$(SRCDIR)
	mkdir -p $@/$(TESTDIR)

$(BUILDDIR)/%.o: ./%.cpp | $(BUILDDIR)
	$(CC) $(INC) $(CXXFLAGS) -c $< -o $@

$(BINDIR)/%: $(OBJECTS) $(BUILDDIR)/% | $(BINDIR)
	$(CXX) $(LIB) $(LDFLAGS) $^ -o $@

run: $(RUN_TARGETS)
	$(foreach target,$^,./$(target) $(INPUT);)

test: $(TEST_TARGETS)
	$(foreach target,$^,./$(target);)
