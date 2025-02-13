namespace Memory {

    // chunks are just very expensive to allocate at runtime so we create a pool at startup to use it on demand
    class ChunkPool {
        array<World::Chunk@> freeChunks;
        array<World::Chunk@> usedChunks;
        int currentCapacity = CHUNK_POOL_INITIAL_CAPACITY;

        ChunkPool() {
            for(int i = 0; i < CHUNK_POOL_INITIAL_CAPACITY; i++) {
                freeChunks.insertLast(@World::Chunk());
            }
        }

        World::Chunk@ GetChunk() {
            if(freeChunks.length() <= 0) {
                __debug("GENERATION CAN'T KEEP UP!\nChunk pool is full! Might happen if render distance is too high or too many players are generating a lot of chunks.\nIf happens repeatedly, send to me steps to reproduce and following info:");
                __debug("Capacity: " + currentCapacity + " / " + CHUNK_POOL_HARD_LIMIT + "\nusedChunks len: " + usedChunks.length());
                DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "GENERATION CAN'T KEEP UP!\nMore info in debug console.");
                return null;
            }

            World::Chunk@ c = @freeChunks[freeChunks.length() - 1];
            freeChunks.removeLast();

            usedChunks.insertLast(c);

            if(freeChunks.length() <= CHUNK_POOL_ENLARGE_AMOUNT) {
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
            int prevCapacity = currentCapacity;
            if(currentCapacity < CHUNK_POOL_HARD_LIMIT - CHUNK_POOL_ENLARGE_AMOUNT) {
                currentCapacity += CHUNK_POOL_ENLARGE_AMOUNT;
            } else {
                currentCapacity = CHUNK_POOL_HARD_LIMIT;
                __debug("Chunk Pool capacity reached hard limit!");
            }
            for(int i = prevCapacity; i < currentCapacity; i++) {
                freeChunks.insertLast(@World::Chunk());
            }
        }

        bool IsRequiresClearing() {
            return usedChunks.length() >= CHUNK_POOL_SOFT_LIMIT;
        }
    }
}