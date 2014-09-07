#include <iostream>
#include <iomanip>
#include <string>
#include "VprPlacementParser.hpp"

int main(int argc, char const* argv[]) {
  VprPlacementFileParser parser(argv[1]);
  parser.init();
  parser.parse();
  std::cout << "Parsed " << parser.blocks.size() << " blocks." << std::endl;

  std::cout << std::endl;
  std::cout
    << "|" << std::setw(24) << "Name"
    << " |" << std::setw(6) << "X"
    << " |" << std::setw(6) << "Y"
    << " |" << std::setw(6) << "Z"
    << " |" << std::setw(7) << "Number"
    << " |" << std::endl;
  std::cout
    << "|-------------------------"
    << "|-------"
    << "|-------"
    << "|-------"
    << "|--------|" << std::endl;
  for (int i = 0; i < parser.blocks.size(); i++) {
    Block const &b = parser.blocks[i];
    std::cout
      << "|" << std::setw(24) << ("`" + b.name + "`")
      << " |" << std::setw(6) << b.x
      << " |" << std::setw(6) << b.y
      << " |" << std::setw(6) << b.subblock
      << " |" << std::setw(7) << b.number
      << " |" << std::endl;
  }
  return 0;
}
