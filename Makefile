CXX := g++
CXXFLAGS := -std=c++11 -msse4.2
LDFLAGS := -stdlib=libc++

INPUT := ../input.txt

BINDIR = bin
SRCDIR := src
BUILDDIR := build
INC := -I include
LIB := -L lib

ALL_SOURCES := $(wildcard $(SRCDIR)/*.cpp)

RUN_SOURCES := $(wildcard $(SRCDIR)/*_main.cpp)
RUN_OBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(RUN_SOURCES:.cpp=.o))
RUN_TARGETS := $(patsubst $(BUILDDIR)/%,$(BINDIR)/%,$(RUN_OBJECTS))

TEST_SOURCES := $(wildcard $(SRCDIR)/*_test.cpp)
TEST_OBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(TEST_SOURCES:.cpp=.o))
TEST_TARGETS := $(patsubst $(BUILDDIR)/%,$(BINDIR)/%,$(TEST_OBJECTS))

SOURCES := $(filter-out $(TEST_SOURCES) $(RUN_SOURCES),$(ALL_SOURCES))
OBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SOURCES:.cpp=.o))

.PHONY: clean test run

.SECONDARY: $(RUN_OBJECTS) $(TEST_OBJECTS) $(OBJECTS)

clean:
	rm -f $(BINDIR)/* $(BUILDDIR)/*

$(BUILDDIR) $(BINDIR):
	mkdir -p $@

$(BUILDDIR)/%.o : $(SRCDIR)/%.cpp | $(BUILDDIR)
	$(CC) $(INC) $(CXXFLAGS) -c $< -o $@

$(BINDIR)/%: $(OBJECTS) $(BUILDDIR)/% | $(BINDIR)
	$(CXX) $(LIB) $(LDFLAGS) $^ -o $@

run: $(RUN_TARGETS)
	$(foreach target,$^,./$(target) $(INPUT);)

test: $(TEST_TARGETS)
	$(foreach target,$^,./$(target);)
