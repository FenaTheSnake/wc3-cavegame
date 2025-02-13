#include "chunkpool.as"
#include "reservedgraphics.as"

namespace Memory {
    ChunkPool@ chunkPool;
    bool initialized;

    void Init() {
        if(initialized) return;
        __debug_section_start("Memory Initialization");

        __debug("Allocating " + RESERVE_GRAPHICS_COUNT + " reserved graphics...");
        AllocateReservedGraphics();

        __debug("Allocating " + CHUNK_POOL_INITIAL_CAPACITY + " chunk pool...");
        @chunkPool = @ChunkPool();

        initialized = true;
        __debug_section_end();
    }
}