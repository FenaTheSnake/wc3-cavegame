namespace World {
    enum ChunkGenerationState {
        UNLOADED = 0,   // chunk has no data
        REQUESTED,      // waiting for host to send data, chunk has no data
        GENERATING,     // is generating (not all blocks are initialized, not safe to work)
        GENERATED,      // all blocks are initialized, but chunk is not shown (safe to work)
        BUILDING,       // is building (all block are initialized but not all are shown, is safe to work)
        BUILT           // all blocks are initialzied and shown. (safe to work)
    }

    class ChunkPos {
        int x, y, z;
        string str;

        ChunkPos() {
            x = 0; y = 0; z = 0; str = "0|0|0";
        }
        ChunkPos(int x, int y, int z) {
            this.x = x;
            this.y = y;
            this.z = z;
            str = x + "|" + y + "|" + z;
        }

        bool opEquals(ChunkPos other) {
            return this.x == other.x and this.y == other.y and this.z == other.z;
        }

        ChunkPos &opAssign(const ChunkPos &in other) {
            this.x = other.x;
            this.y = other.y;
            this.z = other.z;
            this.str = other.str;
            return this;
        }

        ChunkPos(string str) {
            array<string>@ s = str.split("|");
            if(s.length() != 3) {
                x = 0; y = 0; z = 0; str = "0|0|0"; return;
            }

            this.x = parseInt(s[0]);
            this.y = parseInt(s[1]);
            this.z = parseInt(s[2]);
            this.str = str;
        }

        string opImplConv() const { return str; }
    }

    int _debug_chunks_count = 0;

    // The World is consists of box-shaped block chunks (size is defined by CHUNK_SIZE in constants.as).
    // World's (0,0,0) block is (0,0,0) block of (0,0,0) chunk.
    class Chunk {
        ChunkPos position; // pos in world. Ex. (0,0,1) = this chunk starts at (0,0,CHUNK_SIZE)
        ChunkPos on_map_position;   // position on wc3 map (is bound to map limits)
        ChunkGenerationState generationState;

        WorldInstance@ world;
        array<array<array<BlockID>>> blocks(CHUNK_SIZE, array<array<BlockID>>(CHUNK_SIZE, array<BlockID>(CHUNK_SIZE)));
        array<array<array<effect>>> graphics(CHUNK_SIZE, array<array<effect>>(CHUNK_SIZE, array<effect>(CHUNK_SIZE)));
        array<array<array<uint>>> graphics_id(CHUNK_SIZE, array<array<uint>>(CHUNK_SIZE, array<uint>(CHUNK_SIZE, -1)));

        Chunk() {}//_debug_chunks_count++; __debug(_debug_chunks_count+" blocks: " + _debug_blocks_count);}
        Chunk(const ChunkPos &in pos, const WorldInstance@ &in world) {
            position = pos;
            this.world = world;
            generationState = ChunkGenerationState::UNLOADED;
            //_debug_chunks_count++;
            //__debug(_debug_chunks_count+" blocks: " + _debug_blocks_count);
        }

        void UnloadGraphics() {
            if(generationState < ChunkGenerationState::BUILDING) return;

            for(uint i = 0; i < CHUNK_SIZE; i++) {
                for(uint j = 0; j < CHUNK_SIZE; j++) {
                    for(uint k = 0; k < CHUNK_SIZE; k++) {
                        if(graphics_id[i][j][k] != -1) {
                            //if(i == 1 && j == 1 && k == 0) __debug("chunk " + position + " prefree " + graphics_id[i][j][k]);
                            Memory::FreeReservedGraphics(graphics[i][j][k], graphics_id[i][j][k]);
                            graphics[i][j][k] = nil;
                            graphics_id[i][j][k] = -1;
                        }
                    }
                }
            }

            generationState = ChunkGenerationState::GENERATED;
        }

        bool IsBlockPosInBounds(Vector3I &in blockPos) {
            return  blockPos.x >= 0 && blockPos.x < CHUNK_SIZE &&
                    blockPos.y >= 0 && blockPos.y < CHUNK_SIZE &&
                    blockPos.z >= 0 && blockPos.z < CHUNK_SIZE;
        }
        
        // bounds not checked
        BlockPos AbsolutePositionToChunkBlockPos(Vector3 &in pos) {
            Vector3 abspos = Vector3(position.x * CHUNK_SIZE * BLOCK_SIZE, position.y * CHUNK_SIZE * BLOCK_SIZE, position.z * CHUNK_SIZE * BLOCK_SIZE);
            Vector3 p = (pos - abspos) * (1.0f/BLOCK_SIZE);

            //__debug("apcbp: pos: " + pos + "; abspos: " + abspos + "; p: " + p);
            return BlockPos(@this, int(p.x), int(p.y), int(p.z));
        }

        // returns blocks positions
        array<Vector3I>@ GetAABBBlocks(Collision::AABB &in aabb) {
            array<Vector3I> b;

            BlockPos lbd = AbsolutePositionToChunkBlockPos(Vector3(aabb.minX - 64, aabb.minY - 64, aabb.minZ - 64));
            BlockPos rfu = AbsolutePositionToChunkBlockPos(Vector3(aabb.maxX + 64, aabb.maxY + 64, aabb.maxZ + 64));
            //if(position.x == 3 && position.y == 3 && position.z == 3) __debug("lbd " + lbd + "; rfu " + rfu);

            for(int i = lbd.x; i <= rfu.x; i++) {
                for(int j = lbd.y; j <= rfu.y; j++) {
                    for(int k = lbd.z; k <= rfu.z; k++) {
                        Vector3I p = Vector3I(i,j,k);
                        if(IsBlockPosInBounds(p)) {
                            b.insertLast(p);
                        }
                    }
                }
            }

            return @b;
        }

        void SetBlock(BlockPos blockPos, BlockID id) {
            //__debug("SetBlock " + blockPos.chunk.position + ": " + blockPos.x + " " + blockPos.y + " " + blockPos.z);
            blocks[blockPos.x][blockPos.y][blockPos.z] = id;
            Builder::UpdateChunkBlockGraphics(blockPos, true);
            //__debug_section_end();
        }

        string Serialize() {
            string s = position.x + "|" + position.y + "|" + position.z + "|";
            for(int i = 0; i < CHUNK_SIZE; i++) {
                for(int j = 0; j < CHUNK_SIZE; j++) {
                    for(int k = 0; k < CHUNK_SIZE; k++) {
                        s += int(blocks[i][j][k]) + "|";
                    }
                }
            }

            return s;
        }
    }
}