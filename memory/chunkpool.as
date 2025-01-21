namespace Memory {

    // chunks are just very expensive to allocate at runtime so we create a pool at startup to use it on demand
    class ChunkPool {
        array<World::Chunk@> freeChunks;
        array<World::Chunk@> usedChunks;
        int currentCapacity = CHUNK_POOL_MAX_SIZE;

        ChunkPool() {
            for(int i = 0; i < CHUNK_POOL_MAX_SIZE; i++) {
                freeChunks.insertLast(@World::Chunk());
            }
        }

        World::Chunk@ GetChunk() {
            if(freeChunks.length() <= 0) {
                print("GENERATION CAN'T KEEP UP!\nTry lower render distance.\n");
                DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "GENERATION CAN'T KEEP UP!\nTry lower render distance.\n");
                return null;
            }

            World::Chunk@ c = @freeChunks[freeChunks.length() - 1];
            freeChunks.removeLast();

            usedChunks.insertLast(c);

            if(freeChunks.length() <= 256) {
                Enlarge();
            }

            return c;
        }

        void FreeChunk(World::Chunk@ c) {
            int p = usedChunks.findByRef(c);
            if(p < 0) {
                __debug("Attempt to free a chunk that is not used: " + c.position);
                return;
            }

            usedChunks.removeAt(p);
            freeChunks.insertLast(c);
        }

        void Enlarge() {
            currentCapacity += 256;
            for(int i = 0; i < 256; i++) {
                freeChunks.insertLast(@World::Chunk());
            }
        }
    }
}