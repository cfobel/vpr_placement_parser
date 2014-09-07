#ifndef ___VPR_PLACEMENT_PARSER__HPP___
#define ___VPR_PLACEMENT_PARSER__HPP___

#include <fstream>
#include <iostream>
#include <algorithm>
#include <string>
#include <map>
#include <set>
#include <vector>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

using namespace std;

#define DEF_BUFSIZE 32 << 10

template <typename A, typename B, typename C>
inline map<A, B> reverse_map(C &input) {
    map<A, B> r;
    typename C::iterator iter = input.begin();
    for(int i = 0; iter != input.end(); iter++, i++) {
        r[*iter] = i;
    }
    return r;
}


struct Block {
  uint32_t x;
  uint32_t y;
  uint32_t subblock;
  uint32_t number;
  std::string name;
};


class VprPlacementParser {
  void ragel_parse(std::istream &in_stream);
  vector<char> buf_vector;
  char* buf;
  int _BUFSIZE;

  const char *ls;
  const char *ts;
  const char *te;
  const char *be;

  int cs;
  int have;
  int length;
  string temp_str;

  Block current_block;
public:
  vector<Block> blocks;

  VprPlacementParser() { buf_vector = vector<char>(DEF_BUFSIZE); }
  VprPlacementParser(int buffer_size) {
    buf_vector = vector<char>(buffer_size);
  }

  void init();

  virtual void parse(std::istream &in_stream) {
    this->ragel_parse(in_stream);
  }

  virtual void reset() { blocks.clear(); }
};


class VprPlacementFileParser : public VprPlacementParser {
public:
  string placement_filepath_;
  using VprPlacementParser::parse;

  VprPlacementFileParser(string input_filename)
    : VprPlacementParser(), placement_filepath_(input_filename) {}

  void parse() {
    this->reset();
    ifstream in_file(this->placement_filepath_.c_str());
    this->parse(in_file);
    in_file.close();
  }
};
#endif
