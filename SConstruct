grammar_ragel = Command('grammar.cpp', 'grammar.rl',
                        'ragel $SOURCE -o $TARGET')

Program('parser', [grammar_ragel, 'main.cpp'], CCFLAGS=['-g'])
