namespace World {
    enum BlockID {
        AIR = 0,
        GRASS
    }
    class BlockPos {
        Chunk@ chunk;
        int x, y, z;

        BlockPos() {
            this.x = -1; this.y = -1; this.z = -1;
        }
        BlockPos(int x, int y, int z) {
            this.x = x;
            this.y = y;
            this.z = z;
        }
        BlockPos(Chunk@ c, int x, int y, int z) {
            @chunk = @c;
            this.x = x;
            this.y = y;
            this.z = z;
        }

        string opImplConv() const {
            if(chunk is null) {
                return "( - " + this.x + " " + this.y + " " + this.z + ")"; 
            } else {
                return "(" + this.chunk.position + " " + this.x + " " + this.y + " " + this.z + ")"; 
            }
        }
    }

    int _debug_blocks_count = 0;

    class Block {
        BlockID id;
        bool debug;
        effect graphics;

        Block() {
            this.id = BlockID::AIR;
            //_debug_blocks_count++;
        }
        Block(BlockID id) {
            this.id = id;
            //_debug_blocks_count++;
        }
        ~Block() {
           // _debug_blocks_count--;
        }
    }
}