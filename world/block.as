namespace World {
    enum BlockID {
        AIR = 0,
        GRASS,
        DIRT,
        STONE,
        LOG,
        LEAVES,
        CLOUD
    }

    class BlockInfo {
        BlockID id;
        string name;
        string texturePath;
        bool transparent; // has any kind of transparency, would not occlude other blocks

        BlockInfo() {}
        BlockInfo(BlockID id, string name, string texPath, bool transparent) {
            this.id = id; this.name = name; this.texturePath = texPath; this.transparent = transparent;
        }
    }

    const array<BlockInfo> blocksInfo = { 
                                        BlockInfo(BlockID::AIR,     "Air",       "",                     true),
                                        BlockInfo(BlockID::GRASS,   "Grass",     "grassBlock.blp",       false),
                                        BlockInfo(BlockID::DIRT,    "Dirt",      "dirtBlock.blp",        false),
                                        BlockInfo(BlockID::STONE,   "Stone",     "stoneBlock.blp",       false),
                                        BlockInfo(BlockID::LOG,     "Log",       "logBlock.blp",         false),
                                        BlockInfo(BlockID::LEAVES,  "Leaves",    "leavesBlock.blp",      false),
                                        BlockInfo(BlockID::CLOUD,   "Cloud",     "cloudBlock.blp",       true),
                                        };
    const int blocksAmount = blocksInfo.length();

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
        if(id > blocksAmount || id < 0) return "dirtBlock.blp";
        return blocksInfo[id].texturePath;

        // if(id == BlockID::GRASS) return "grassBlock.blp";
        // if(id == BlockID::STONE) return "stoneBlock.blp";
        // if(id == BlockID::LOG) return "logBlock.blp";
        // if(id == BlockID::LEAVES) return "leavesBlock.blp";
        // if(id == BlockID::CLOUD) return "cloudBlock.blp";
        
        // return "dirtBlock.blp";
    }

    string BlockID2Name(BlockID id) {
        if(id > blocksAmount || id < 0) return "Unknown";
        return blocksInfo[id].name;
    }

    bool BlockHasTransparency(BlockID id) {
        if(id > blocksAmount || id < 0) return true;
        return blocksInfo[id].transparent;
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