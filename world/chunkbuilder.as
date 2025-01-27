namespace World {
    namespace Builder {
        class BuildingChunkData {
            Chunk@ chunk;
            uint i, j ,k;    // block that we ended at last time

            BuildingChunkData() {}
            BuildingChunkData(Chunk@ chunk) {
                @this.chunk = @chunk;
                i = 0; j = 0; k = 0;
            }
        }

        array<BuildingChunkData> chunksBeingBuilt;

        int processedBuildingBlocks = 0;
        void ProcessBuildingChunks() {
            processedBuildingBlocks = 0;

            for(uint chunk_iter = 0; chunk_iter < chunksBeingBuilt.length(); chunk_iter++) {
                BuildingChunkData@ data = @chunksBeingBuilt[chunk_iter];
                if(data.chunk.generationState != ChunkGenerationState::BUILDING) {
                    chunksBeingBuilt.removeAt(chunk_iter);
                    chunk_iter--;
                    continue;
                }

                ChunkPos wc3Position = data.chunk.on_map_position;
                //bool isBorder = World::IsBorderChunk(wc3Position);
                //data.chunk._wasBorderChunk = isBorder;

                for(uint i = 0; i < CHUNK_SIZE; i++) {
                    for(uint j = 0; j < CHUNK_SIZE; j++) {
                        for(uint k = 0; k < CHUNK_SIZE; k++) {

                            if(data.i != 0 || data.j != 0 || data.k != 0) {
                                i = data.i; j = data.j; k = data.k;
                                data.i = 0; data.j = 0; data.k = 0;
                            }
                            if(processedBuildingBlocks > Main::toBuildBlocks) {
                                data.i = i; data.j = j; data.k = k;
                                return;
                            }

                            BlockID b = data.chunk.blocks[i][j][k];
                            //__debug(""+data.chunk.graphics[i][j][k]);
                            if(data.chunk.graphics_id[i][j][k] != -1) continue;
                            processedBuildingBlocks++;
        
                            if(b != BlockID::AIR) {
                                if(data.chunk.world.IsBlockOccluded(data.chunk.position, i, j, k)) {
                                    data.chunk.graphics_id[i][j][k] = -1;
                                    //__debug("builder::occluded " + data.chunk.position.x + i + " " + data.chunk.position.y + j + " " + data.chunk.position.z + k + ", chunkPos " + data.chunk.position);
                                    continue;
                                }

                                data.chunk.graphics[i][j][k] = Memory::GetReservedGraphics(data.chunk.graphics_id[i][j][k]);
                                //if(i == 1 && j == 1 && k == 0) __debug("chunk " + data.chunk.position + " after id " + data.chunk.graphics_id[i][j][k]);
                                SetSpecialEffectPositionWithZ(data.chunk.graphics[i][j][k], wc3Position.x * CHUNK_SIZE * BLOCK_SIZE + i * BLOCK_SIZE, wc3Position.y * CHUNK_SIZE * BLOCK_SIZE + j * BLOCK_SIZE, wc3Position.z * CHUNK_SIZE * BLOCK_SIZE + k*BLOCK_SIZE);
                                SetSpecialEffectMaterialTexture(data.chunk.graphics[i][j][k], BlockID2Texture(b), 0, 0);
                                //if(b.debug) SetSpecialEffectVertexColour(b.graphics.get().eff, 255, 92, 92, 255);
                                //else SetSpecialEffectVertexColour(b.graphics.get().eff, 255, 255, 255, 255);
                            } else {
                                data.chunk.graphics_id[i][j][k] = -1;
                            }
                        }
                    }
                }

                //__debug("graphics 1 1 0: " + data.chunk.graphics_id[1][1][0]);
                data.chunk.generationState = ChunkGenerationState::BUILT;
                data.chunk.world.builtChunks.insertLast(@data.chunk);
                chunksBeingBuilt.removeAt(chunk_iter);
                chunk_iter--;

            }
        }

        // Sends chunk to list of chunks to be built later.
        // thus the returned chunk is not shown immediately!
        bool BuildChunk(Chunk@ chunk) {
            if(chunk.generationState != ChunkGenerationState::GENERATED) {
                return false;
            }

            chunk.generationState = ChunkGenerationState::BUILDING;
            chunk.on_map_position = World::ChunkPosToWC3Position(chunk.position);
            chunksBeingBuilt.insertLast(BuildingChunkData(@chunk));

            return true;
        }

        // update chunk's graphics position to new chunk's position
        void RepositionChunk(Chunk@ chunk) {
            ChunkPos wc3Position = chunk.on_map_position;
            for(uint i = 0; i < CHUNK_SIZE; i++) {
                for(uint j = 0; j < CHUNK_SIZE; j++) {
                    for(uint k = 0; k < CHUNK_SIZE; k++) {
                        if(chunk.graphics_id[i][j][k] == -1) continue;
    
                        if(chunk.blocks[i][j][k] != BlockID::AIR) {
                            if(chunk.world.IsBlockOccluded(chunk.position, i, j, k)) {
                                continue;
                            }

                            SetSpecialEffectPositionWithZ(chunk.graphics[i][j][k], wc3Position.x * CHUNK_SIZE * BLOCK_SIZE + i * 128, wc3Position.y * CHUNK_SIZE * BLOCK_SIZE + j * 128, wc3Position.z * CHUNK_SIZE * BLOCK_SIZE + k*128);
                        }
                    }
                }
            }
        }

        void UpdateChunkBlockGraphics(BlockPos blockPos, bool updateNeighbors) {
            if(blockPos.chunk == null) return;
            BlockID b = blockPos.chunk.blocks[blockPos.x][blockPos.y][blockPos.z];
            effect g = blockPos.chunk.graphics[blockPos.x][blockPos.y][blockPos.z];
            uint g_id = blockPos.chunk.graphics_id[blockPos.x][blockPos.y][blockPos.z];

            if(b == BlockID::AIR || blockPos.chunk.world.IsBlockOccluded(blockPos.chunk.position, blockPos.x, blockPos.y, blockPos.z)) {
                if(g_id != -1) {
                    Memory::FreeReservedGraphics(g, blockPos.chunk.graphics_id[blockPos.x][blockPos.y][blockPos.z]);
                    blockPos.chunk.graphics[blockPos.x][blockPos.y][blockPos.z] = nil;
                    blockPos.chunk.graphics_id[blockPos.x][blockPos.y][blockPos.z] = -1;
                }
            } else {
                if(g_id == -1 && !blockPos.chunk.world.IsBlockOccluded(blockPos.chunk.position, blockPos.x, blockPos.y, blockPos.z)) {
                    ChunkPos wc3Position = blockPos.chunk.on_map_position;
                    blockPos.chunk.graphics[blockPos.x][blockPos.y][blockPos.z] = Memory::GetReservedGraphics(blockPos.chunk.graphics_id[blockPos.x][blockPos.y][blockPos.z]);
                    SetSpecialEffectMaterialTexture(blockPos.chunk.graphics[blockPos.x][blockPos.y][blockPos.z], BlockID2Texture(b), 0, 0);
                    SetSpecialEffectPositionWithZ(blockPos.chunk.graphics[blockPos.x][blockPos.y][blockPos.z],    
                                                        wc3Position.x * CHUNK_SIZE * BLOCK_SIZE + blockPos.x * BLOCK_SIZE, 
                                                        wc3Position.y * CHUNK_SIZE * BLOCK_SIZE + blockPos.y * BLOCK_SIZE, 
                                                        wc3Position.z * CHUNK_SIZE * BLOCK_SIZE + blockPos.z * BLOCK_SIZE);
                }
            }

            if(updateNeighbors) {
                ChunkPos pos = blockPos.chunk.position;
                //__debug("checking left");
                if(blockPos.x - 1 == -1) {
                    ChunkPos posL = ChunkPos(pos.x - 1, pos.y, pos.z);
                    if(blockPos.chunk.world.loadedChunks.exists(posL)) {
                        Chunk@ cl = cast<Chunk@>(blockPos.chunk.world.loadedChunks[posL]);
                        UpdateChunkBlockGraphics(BlockPos(@cl, CHUNK_SIZE - 1, blockPos.y, blockPos.z), false);
                    }
                } else UpdateChunkBlockGraphics(BlockPos(@blockPos.chunk, blockPos.x - 1, blockPos.y, blockPos.z), false);
                //__debug("checking right");
                if(blockPos.x + 1 == CHUNK_SIZE) {
                    ChunkPos posR = ChunkPos(pos.x + 1, pos.y, pos.z);
                    if(blockPos.chunk.world.loadedChunks.exists(posR)) {
                        Chunk@ cr = cast<Chunk@>(blockPos.chunk.world.loadedChunks[posR]);
                        UpdateChunkBlockGraphics(BlockPos(@cr, 0, blockPos.y, blockPos.z), false);
                    }
                } else UpdateChunkBlockGraphics(BlockPos(@blockPos.chunk, blockPos.x + 1, blockPos.y, blockPos.z), false);

                //__debug("checking back");
                if(blockPos.y - 1 == -1) {
                    ChunkPos posB = ChunkPos(pos.x, pos.y - 1, pos.z);
                    if(blockPos.chunk.world.loadedChunks.exists(posB)) {
                        Chunk@ cb = cast<Chunk@>(blockPos.chunk.world.loadedChunks[posB]);
                        UpdateChunkBlockGraphics(BlockPos(@cb, blockPos.x, CHUNK_SIZE - 1, blockPos.z), false);
                    }
                } else UpdateChunkBlockGraphics(BlockPos(@blockPos.chunk, blockPos.x, blockPos.y - 1, blockPos.z), false);
                //__debug("checking front");
                if(blockPos.y + 1 == CHUNK_SIZE) {
                    ChunkPos posF = ChunkPos(pos.x, pos.y + 1, pos.z);
                    if(blockPos.chunk.world.loadedChunks.exists(posF)) {
                        Chunk@ cf = cast<Chunk@>(blockPos.chunk.world.loadedChunks[posF]);
                        UpdateChunkBlockGraphics(BlockPos(@cf, blockPos.x, 0, blockPos.z), false);
                    }
                } else UpdateChunkBlockGraphics(BlockPos(@blockPos.chunk, blockPos.x, blockPos.y + 1, blockPos.z), false);
                //__debug("checking down");
                if(blockPos.z - 1 == -1) {
                    ChunkPos posD = ChunkPos(pos.x, pos.y, pos.z - 1);
                    if(blockPos.chunk.world.loadedChunks.exists(posD)) {
                        Chunk@ cd = cast<Chunk@>(blockPos.chunk.world.loadedChunks[posD]);
                        UpdateChunkBlockGraphics(BlockPos(@cd, blockPos.x, blockPos.y, CHUNK_SIZE - 1), false);
                    }
                } else UpdateChunkBlockGraphics(BlockPos(@blockPos.chunk, blockPos.x, blockPos.y, blockPos.z - 1), false);
                //__debug("checking up");
                if(blockPos.z + 1 == CHUNK_SIZE) {
                    ChunkPos posU = ChunkPos(pos.x, pos.y, pos.z + 1);
                    if(blockPos.chunk.world.loadedChunks.exists(posU)) {
                        Chunk@ cu = cast<Chunk@>(blockPos.chunk.world.loadedChunks[posU]);
                        UpdateChunkBlockGraphics(BlockPos(@cu, blockPos.x, blockPos.y, 0), false);
                    }
                } else UpdateChunkBlockGraphics(BlockPos(@blockPos.chunk, blockPos.x, blockPos.y, blockPos.z + 1), false);
            }
        }
    }
}