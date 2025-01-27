namespace World {
    enum BlockID {
        AIR = 0,
        GRASS,
        DIRT,
        STONE,
        LOG,
        LEAVES
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

    class ScheduledBlock {
        BlockPos bpos;
        BlockID id;

        ScheduledBlock(BlockPos &in bpos, BlockID &in id) {
            this.bpos = bpos;
            this.id = id;
        }
    }

    string BlockID2Texture(BlockID id) {
        if(id == BlockID::GRASS) return "grassBlock.blp";
        if(id == BlockID::STONE) return "stoneBlock.blp";
        if(id == BlockID::LOG) return "logBlock.blp";
        if(id == BlockID::LEAVES) return "leavesBlock.blp";
        
        return "dirtBlock.blp";
    }

    int _debug_blocks_count = 0;

    class Block {
        BlockID id;
        bool debug;

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