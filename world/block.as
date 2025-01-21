namespace World {
    enum BlockID {
        AIR = 0,
        GRASS
    }

    int _debug_blocks_count = 0;

    class Block {
        BlockID id;
        bool debug;
        weakref<Memory::ReservedGraphics> graphics;

        Block() {
            this.id = BlockID::AIR;
            _debug_blocks_count++;
        }
        Block(BlockID id) {
            this.id = id;
            _debug_blocks_count++;
        }
        ~Block() {
            _debug_blocks_count--;
        }
    }
}