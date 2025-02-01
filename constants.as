// == CORE ==

const int CHUNK_SIZE = 8;   // should be divisible by Block_Size. Travelling by Z coordinate might be broken if too high.
const int BLOCK_SIZE = 128; // must be same as 'block.mdx' size
const int MAP_SIZE = 256;   // num. of blocks that can fit in one dimension. must be in sync with actual map size (or atleast not larger than actual map)
const int MAP_SIZE_Z = 8192 / BLOCK_SIZE;  // wc3's camera's Z coordinate is clamped between -4096 and 4096
                                                        // no words can describe my emotions after me finding this out
                                                        // anyway this is not fatal, we just loop this shit as with other coordinates
                                                        // but now chunk size is limited to 8, 16 is too big unfortunately.


// == MEMORY ==
const int RESERVE_GRAPHICS_COUNT = 256*256;   // reserve graphics = 'effect's that are used for displaying blocks.
                                            // they are allocated at startup at once and just reused on demand.
const int CHUNK_POOL_INITIAL_CAPACITY = 1024;   // num. of chunks allocated at startup
const int CHUNK_POOL_SOFT_LIMIT = 8192;         // num. of chunks after which the game would began to unload unrelevant chunks from memory
const int CHUNK_POOL_HARD_LIMIT = 10000;        // max amount of chunks that can be allocated
const int CHUNK_POOL_ENLARGE_AMOUNT = 256;      // amount of new chunks that allocated at runtime when chunk pool capacity's is almost full.

const int MAX_GENERATED_BLOCKS_AT_ONCE = 4096;  // maximum amount of blocks that will be processed at once when generating chunk
                                                // (if exceed, generation will be paused and continued later)
const int MAX_BUILT_BLOCKS_AT_ONCE = 2048;       // same as above but for building blocks (building = processing what faces should be shown and placing graphics)

// == TIMERS ==
const float TIME_PLAYER_UPDATE = 0.01f;
const float TIME_WORLD_UPDATE = 0.05f;
const float TIME_GUI_UPDATE = 0.15f;
const float TIME_MP_UPDATE = 0.2f;


// == PLAYER ==
const double PLAYER_HEIGHT = BLOCK_SIZE * 1.75;       // why not 1.75? because fuck my life i guess (if you're too curious, try it yourself and spot the difference)
const double PLAYER_SIZE = BLOCK_SIZE * 0.75;       
const double PLAYER_BLOCK_SNAP_QUALITY = BLOCK_SIZE / 10.0;   // larger = less block edge check quality while sneaking.
const double PLAYER_STEPHEIGHT = BLOCK_SIZE/2.0;

const float PLAYER_DEFAULT_EYES_POSITION = PLAYER_HEIGHT / 2 - 25.0f;
const float PLAYER_SNEAKING_EYES_POSITION = PLAYER_HEIGHT / 2 - 60.0f;

const float PLAYER_DEFAULT_SPEED = 1.0f;
const float PLAYER_SPRINTING_SPEED = 1.75f;
const float PLAYER_SNEAKING_SPEED = 0.4f;

const float PLAYER_DEFAULT_FOV = 110.0f;
const float PLAYER_SPRINTING_FOV = PLAYER_DEFAULT_FOV + 10.0f;

const float PLAYER_JUMP_STRENGTH = 9.6667f;
const float PLAYER_MAX_FALLING_SPEED = -24.0f;

const float GRAVITY = 16;

const float DOUBLE_JUMP_DELAY = 1.0f; // interval in seconds when you can press jump second time to enable flying mode


// == MATH ==

const float EPSILON = 1e-9;


// == SAVE ==

const string PATH_MAP_ROOT = "cavegame\\";
const string PATH_SAVES = PATH_MAP_ROOT + "saves\\";
const string PATH_CHUNKS_FILE = "chunks";
const string PATH_WORLD_FILE = "world";
const string SAVE_EXTENSION = ".txt";

const string PATH_GLOBAL_WORLD_LIST_FILE = "worldlist";

const int SAVE_CHUNK_MAX_AMOUNT = 0x00000FFF;             // max amount of chunks per chunkfile
const int SAVE_CHUNK_SERIALIZATION_SIZE = 1550;     // size of each chunk serialized data in bytes (UNUSED)
const int SAVE_BLOCK_INDEX_OFFSET = 32;

// == MULTIPLAYER ==

const string MP_SYNCCHUNK_PREFIX = "sc";
const string MP_SETBLOCK_PREFIX = "sb";
const string MP_CREATEWORLD_PREFIX = "cw";
const string MP_SYNCWORLD_PREFIX = "sw";
const string MP_SYNCWORLD_END_PREFIX = "se";

const int MP_SYNCHT_POS_X = 0;
const int MP_SYNCHT_POS_Y = 1;
const int MP_SYNCHT_POS_Z = 2;
const int MP_SYNCHT_FACING = 3;

// == GUI ==

const int WORLD_LIST_PAGE_ITEMS_COUNT = 20;

// == ATTENTIONS ==
const int ATTENTION_WAITING_FOR_HOST = 'host';
const int ATTENTION_LOADING_CHUNKS = 'chld';
const int ATTENTION_SAVING_WORLD = 'save';
const int ATTENTION_SYNCING_WORLD = 'sync';
const string ATTENTION_WAITING_FOR_HOST_TEXT = "Waiting for host to select a world...";
const string ATTENTION_LOADING_CHUNKS_TEXT = "Loading chunks...";
const string ATTENTION_SAVING_WORLD_TEXT = "Saving world...";
const string ATTENTION_SYNCING_WORLD_TEXT = "Synchronizing world ";