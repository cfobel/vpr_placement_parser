#include <string>
#include <stdexcept>
#include "VprPlacementParser.hpp"

%%{
    machine VprPlacementParser;

    action start_block_name { ts = fpc; }
    action end_block_name { current_block.name = std::string(ts, fpc - ts); }
    action start_x { ts = fpc; }
    action end_x {
        temp_str = std::string(ts, fpc - ts);
        current_block.x = atoi(temp_str.c_str());
    }
    action start_y { ts = fpc; }
    action end_y {
        temp_str = std::string(ts, fpc - ts);
        current_block.y = atoi(temp_str.c_str());
    }
    action start_subblock { ts = fpc; }
    action end_subblock {
        temp_str = std::string(ts, fpc - ts);
        current_block.subblock = atoi(temp_str.c_str());
    }
    action start_block_number { ts = fpc; }
    action end_block_number {
        temp_str = std::string(ts, fpc - ts);
        current_block.number = atoi(temp_str.c_str());
    }
    action end_block {
        blocks.push_back(current_block);
    }
    action end_comment {}
    action end_emptyline {}
    action end_firstline {}
    action end_arraysizeline {}

    # Words in a line.
    word = ^[ \t\n]+;

    # The whitespace separating words in a line.
    whitespace = [ \t];

    block_name = word >start_block_name %end_block_name; 
    x = digit+ >start_x %end_x;
    y = digit+ >start_y %end_y;
    subblock = digit+ >start_subblock %end_subblock;
    block_number = digit+ >start_block_number %end_block_number;

    separator = ('\\\n' | whitespace);

    comment = ( '#' (whitespace* word)** ) %end_comment;
    endofline = ( comment? whitespace* '\n' );
    emptyline = whitespace* endofline %end_emptyline;
    firstline = ('Netlist file:' whitespace+ word whitespace+ 'Architecture file:' whitespace+ word endofline) %end_firstline;
    arraysizeline = ('Array size:' whitespace+ digit+ whitespace+ 'x' whitespace+ digit+ whitespace+ 'logic blocks' endofline) %end_arraysizeline;

    block = (block_name whitespace+ x whitespace+ y
             whitespace+ subblock whitespace+ '#' block_number '\n') %end_block;

    # Any number of lines.
    main := (emptyline | firstline | arraysizeline | comment | block)+;
}%%


/* Regal data ****************************************/
%% write data nofinal;
/* Regal data: end ***********************************/

void VprPlacementParser::init() {
    buf = &buf_vector[0];
    _BUFSIZE = buf_vector.size() - 1;

    %% write init;
}


void VprPlacementParser::ragel_parse(std::istream &in_stream) {
    bool done = false;
    int i = 0;
    have = 0;
    while ( !done ) {
        /* How much space is in the buffer? */
        int space = _BUFSIZE - have;
        if ( space == 0 ) {
            /* Buffer is full. */
            cerr << "TOKEN TOO BIG" << endl;
            exit(1);
        }
        /* Read in a block after any data we already have. */
        char *p = buf + have;
        in_stream.read(p, space);
        int len = in_stream.gcount();
        char *pe = p + len;
        char *eof = 0;

        /* If no data was read indicate EOF. */
        if ( len == 0 ) {
            eof = pe;
            done = true;
        } else {
            %% write exec;

            if ( cs == VprPlacementParser_error ) {
                /* Machine failed before finding a token. */
                cerr << "PARSE ERROR" << endl;
                /*exit(1);*/
                throw std::runtime_error("PARSE ERROR");
            }
            if ( ts == 0 ) {
                have = 0;
            } else {
                /* There is a prefix to preserve, shift it over. */
                have = pe - ts;
                memmove( buf, ts, have );
                te = buf + (te-ts);
                ts = buf;
            }
        }
    }
}
