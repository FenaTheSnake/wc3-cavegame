#include "chunkpool.as"
#include "reservedgraphics.as"

namespace Memory {
    ChunkPool@ chunkPool;

    void Init() {
        __debug_section_start("Memory Initialization");

        __debug("Allocating reserved graphics...");
        AllocateReservedGraphics();

        __debug("Allocating chunk pool...");
        @chunkPool = @ChunkPool();

        __debug_section_end();
    }
}