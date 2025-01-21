const int CHUNK_SIZE = 8;   // should be divisible by Block_Size. Travelling by Z coordinate might be broken if too high.
const int BLOCK_SIZE = 128; // must be same as 'block.mdx' size
const int MAP_SIZE = 256;   // num. of blocks that can fit in one dimension. must be in sync with actual map size (or atleast not larger than actual map)
const int MAP_SIZE_Z = 8192 / BLOCK_SIZE;  // wc3's camera's Z coordinate is clamped between -4096 and 4096
                                                        // no words can describe my emotions after me finding this out
                                                        // anyway this is not fatal, we just loop this shit as with other coordinates
                                                        // but now chunk size is limited to 8, 16 is too big unfortunately.

const int RESERVE_GRAPHICS_COUNT = 256*256;   // reserve graphics = 'effect's that are used for displaying blocks.
                                            // they are allocated at startup at once and just reused on demand.
const int CHUNK_POOL_MAX_SIZE = 1024;    // TODO make chunk pools dynamically resizable (Host needs to store alot of them)

const int MAX_GENERATED_BLOCKS_AT_ONCE = 32768;  // maximum amount of blocks that will be processed at once when generating chunk
                                                // (if exceed, generation will be paused and continued later)
const int MAX_BUILT_BLOCKS_AT_ONCE = 8192;       // same as above but for building blocks (building = processing what faces should be shown and placing graphics)

const float PLAYER_HEIGHT = BLOCK_SIZE * 1.75f;
const float PLAYER_SIZE = BLOCK_SIZE * 0.75f;

const float EPSILON = 1e-5;