CXX := g++
CXXFLAGS := -std=c++11 -msse4.2 -O3
LDFLAGS := -stdlib=libc++

INPUT := ./data/sample_10k.txt

BINDIR = bin
SRCDIR := src
TESTDIR := tests
BUILDDIR := build
INC := -I include
LIB := -L lib

ALL_SOURCES := $(wildcard $(SRCDIR)/*.cpp $(TESTDIR)/*.cpp)

RUN_SOURCES := $(wildcard $(SRCDIR)/*_main.cpp $(TESTDIR)/*_main.cpp)
RUN_OBJECTS := $(patsubst %,$(BUILDDIR)/%, $(RUN_SOURCES:.cpp=.o))
RUN_TARGETS := $(patsubst $(BUILDDIR)/%.o, $(BINDIR)/%, $(RUN_OBJECTS))

TEST_SOURCES := $(wildcard $(TESTDIR)/test_*.cpp)
TEST_OBJECTS := $(patsubst %,$(BUILDDIR)/%, $(TEST_SOURCES:.cpp=.o))
TEST_TARGETS := $(patsubst $(BUILDDIR)/%.o, $(BINDIR)/%, $(TEST_OBJECTS))

SOURCES := $(filter-out $(RUN_SOURCES) $(TEST_SOURCES), $(ALL_SOURCES))
OBJECTS := $(patsubst %,$(BUILDDIR)/%, $(SOURCES:.cpp=.o))

.PHONY: clean test run

.SECONDARY: $(RUN_OBJECTS) $(TEST_OBJECTS) $(OBJECTS)

clean:
	rm -rf ./$(BINDIR)/ ./$(BUILDDIR)/

$(BUILDDIR)/%.o: ./%.cpp
	@mkdir -p $(dir $@)
	$(CC) $(INC) $(CXXFLAGS) -c $< -o $@

$(BINDIR)/%: $(OBJECTS) $(BUILDDIR)/%.o
	@mkdir -p $(dir $@)
	$(CXX) $(LIB) $(LDFLAGS) $^ -o $@

run: $(RUN_TARGETS)
	@for target in $(RUN_TARGETS); do \
		echo $$target >&2; \
		time ./$$target $(INPUT); \
		done

test: $(TEST_TARGETS)
	$(foreach target,$^,./$(target);)
